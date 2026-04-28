// CacheManager.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CryptoKit

/// Manages in-memory and disk caching for weather data with configurable TTL.
/// Thread safety is provided by a concurrent dispatch queue with barrier writes.
final class CacheManager: @unchecked Sendable {

    // MARK: - Cache Entry

    fileprivate struct CacheEntry<T> {
        let value: T
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    // MARK: - Properties

    private let memoryCache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.pews.cache", attributes: .concurrent)

    // MARK: - Initialization

    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("PEWSCache")

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }

        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }

    // MARK: - Memory Cache

    func setMemory<T>(_ value: T, forKey key: String, ttl: TimeInterval) {
        let entry = CacheEntry(value: value, timestamp: Date(), ttl: ttl)
        let wrapper = CacheEntryWrapper(entry: entry)
        memoryCache.setObject(wrapper, forKey: key as NSString)
    }

    func getMemory<T>(forKey key: String) -> T? {
        guard let wrapper = memoryCache.object(forKey: key as NSString) as? CacheEntryWrapper<T> else {
            return nil
        }
        guard !wrapper.entry.isExpired else {
            memoryCache.removeObject(forKey: key as NSString)
            return nil
        }
        return wrapper.entry.value
    }

    // MARK: - Disk Cache

    func setDisk<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            let entry = DiskCacheEntry(
                data: try? self.encoder.encode(value),
                timestamp: Date(),
                ttl: ttl
            )
            let fileURL = self.cacheDirectory.appendingPathComponent(key.sha256Hash)
            if let entryData = try? self.encoder.encode(entry) {
                try? entryData.write(to: fileURL)
            }
        }
    }

    func getDisk<T: Codable>(forKey key: String) -> T? {
        var result: T?
        queue.sync {
            let fileURL = cacheDirectory.appendingPathComponent(key.sha256Hash)
            guard let data = try? Data(contentsOf: fileURL),
                  let entry = try? decoder.decode(DiskCacheEntry.self, from: data),
                  !entry.isExpired,
                  let entryData = entry.data,
                  let value = try? decoder.decode(T.self, from: entryData) else {
                return
            }
            result = value
        }
        return result
    }

    // MARK: - Combined Cache (Memory + Disk)

    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) {
        setMemory(value, forKey: key, ttl: ttl)
        setDisk(value, forKey: key, ttl: ttl)
    }

    func get<T: Codable>(forKey key: String) -> T? {
        if let memoryValue: T = getMemory(forKey: key) {
            return memoryValue
        }
        if let diskValue: T = getDisk(forKey: key) {
            setMemory(diskValue, forKey: key, ttl: AppConfig.CacheDuration.currentWeather)
            return diskValue
        }
        return nil
    }

    // MARK: - Cache Invalidation

    func remove(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent(key.sha256Hash)
        try? fileManager.removeItem(at: fileURL)
    }

    func clearAll() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    var diskCacheSize: Int {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + size
        }
    }
}

// MARK: - Cache Entry Wrapper (for NSCache)

private class CacheEntryWrapper<T>: NSObject {
    let entry: CacheManager.CacheEntry<T>

    init(entry: CacheManager.CacheEntry<T>) {
        self.entry = entry
    }
}

// MARK: - Disk Cache Entry

private struct DiskCacheEntry: Codable {
    let data: Data?
    let timestamp: Date
    let ttl: TimeInterval

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}

// MARK: - SHA-256 Hashing

private extension String {
    var sha256Hash: String {
        let data = Data(self.utf8)
        let digest = SHA256.hash(data: data)
        return digest.prefix(16).map { String(format: "%02x", $0) }.joined()
    }
}
