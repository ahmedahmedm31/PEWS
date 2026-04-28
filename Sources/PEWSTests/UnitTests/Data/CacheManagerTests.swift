// CacheManagerTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class CacheManagerTests: XCTestCase {

    private var sut: CacheManager!

    override func setUp() {
        super.setUp()
        sut = CacheManager()
        sut.clearAll()
    }

    override func tearDown() {
        sut.clearAll()
        sut = nil
        super.tearDown()
    }

    // MARK: - Cache Tests

    func testCacheAndRetrieve() {
        let testValue = "Hello, World!"
        sut.set(testValue, forKey: "test_key", ttl: 3600)

        let retrieved: String? = sut.get(forKey: "test_key")
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, "Hello, World!")
    }

    func testCacheMiss() {
        let retrieved: String? = sut.get(forKey: "nonexistent_key")
        XCTAssertNil(retrieved)
    }

    func testCacheOverwrite() {
        sut.set("First", forKey: "key", ttl: 3600)
        sut.set("Second", forKey: "key", ttl: 3600)

        let retrieved: String? = sut.get(forKey: "key")
        XCTAssertEqual(retrieved, "Second")
    }

    func testClearAll() {
        sut.set("Test1", forKey: "key1", ttl: 3600)
        sut.set("Test2", forKey: "key2", ttl: 3600)

        sut.clearAll()

        let val1: String? = sut.get(forKey: "key1")
        let val2: String? = sut.get(forKey: "key2")
        XCTAssertNil(val1)
        XCTAssertNil(val2)
    }

    func testRemoveSpecificKey() {
        sut.set("Test1", forKey: "key1", ttl: 3600)
        sut.set("Test2", forKey: "key2", ttl: 3600)

        sut.remove(forKey: "key1")

        let val1: String? = sut.get(forKey: "key1")
        let val2: String? = sut.get(forKey: "key2")
        XCTAssertNil(val1)
        XCTAssertNotNil(val2)
    }

    // MARK: - Memory Cache Tests

    func testMemoryCacheSetAndGet() {
        sut.setMemory("MemoryValue", forKey: "mem_key", ttl: 3600)

        let retrieved: String? = sut.getMemory(forKey: "mem_key")
        XCTAssertEqual(retrieved, "MemoryValue")
    }

    func testMemoryCacheExpiration() {
        sut.setMemory("Expired", forKey: "expired_key", ttl: -1) // Already expired

        let retrieved: String? = sut.getMemory(forKey: "expired_key")
        XCTAssertNil(retrieved, "Expired memory cache should return nil")
    }

    // MARK: - Disk Cache Size

    func testDiskCacheSizeInitiallyZero() {
        sut.clearAll()
        XCTAssertEqual(sut.diskCacheSize, 0)
    }
}
