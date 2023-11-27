//
//  AppDatabase.swift
//  GDRB-Issues
//
//  Created by Marcel Bradea on 2023-11-27.
//

import Foundation
import os.log
import GRDB


public class AppDatabase {

	//
	// MARK: constants
	//

	private static let InMemoryDB = ":memory:"
	private static let TempDB = ""
	private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
	static var shared:AppDatabase!


	//
	// MARK: state
	//

	public static var configuration:Configuration {
		var config = Configuration()

		// logging
		// NOTE: log SQL statements if the `SQL_TRACE` environment variable is set
		// REF: https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)
		if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
			config.prepareDatabase { db in
					db.trace {
						// It's ok to log statements publicly. Sensitive
						// information (statement arguments) are not logged
						// unless config.publicStatementArguments is set
						// (see below).
						os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
				}
			}
		}

		// protect sensitive information
		// REF:https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments
		#if DEBUG
		config.publicStatementArguments = true
		#endif

		return config
	}
	var reader:DatabaseReader { writer }
	let writer:any DatabaseWriter
	
	
	//
	// MARK: lifecycle
	//

	convenience init(mode:DatabaseMode = .connectionPool) throws {
		// in-memory
		guard mode != .inMemory else {
			let databaseQueue = try DatabaseQueue(named: Self.TempDB, configuration: AppDatabase.configuration)
			print("Database located at '\(databaseQueue.path)'")
			try self.init(writer: databaseQueue)
			return
		}
		
		fatalError("TODO")
//		let dbPath:String = try letThrowing(FileManager.default){ (fileManager:FileManager) throws in
//			let databaseFile:URL = try letThrowing(
//				// A1: root Application Support dir >> doesn't work
////				try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//				// A2: sub-dir
////				`let`(
//				try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
////				){ (appSupportDirectory:URL) in
////					appSupportDirectory.appendingPathComponent("Data", isDirectory: true)
////				}
//			){ (databaseDirectory:URL) in
////				try fileManager.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
//				databaseDirectory.appendingPathComponent("DB.sqlite")
//			}
//			if #available( iOS 16, * ){
//				return databaseFile.path( percentEncoded: false )
//			} else {
//				return databaseFile.path
//			}
//		}
//		let databaseWriter:any DatabaseWriter = switch mode {
//			case .inMemory: Assert.fail("IMPOSSIBLE. Guarded against above.")
//			case .singleConnection: try DatabaseQueue(path: dbPath, configuration: AppDatabase.configuration)
//			case .connectionPool: try DatabasePool(path: dbPath, configuration: AppDatabase.configuration)
//		}
//		print("Database located at '\(databaseWriter.path)'")
//		try self.init( writer: databaseWriter )
	}

	
	private init(writer:any DatabaseWriter) throws {
		self.writer = writer

		// migrations
		// TODO: GARBAGE?
//		try migrator.migrate(writer)
	}
	
	
	//
	// MARK: operations
	//
	
	static func DEBUG_designTimeDatabase() -> AppDatabase {
		try! AppDatabase(mode: .inMemory)
	}
	
	
	//
	// MARK: outer structures
	//
	
	enum DatabaseMode {
		case
			inMemory,
			singleConnection,
			connectionPool
	}

}
