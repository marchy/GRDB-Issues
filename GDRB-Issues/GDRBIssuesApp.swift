//
//  GDRB_IssuesApp.swift
//  GDRB-Issues
//
//  Created by Marcel Bradea on 2023-11-27.
//

import SwiftUI
import GRDB


@main
struct GDRBIssuesApp : App {
	
	//
	// MARK: lifecycle
	//
	
	init() {
		//
		// bootstrap
		//
		// database
		do {
			AppDatabase.shared = /*with(*/try AppDatabase(mode: .inMemory)/*){ database in
				SharedDatabaseReader = database.reader
				SharedDatabaseWriter = database.writer
			}*/
		} catch let error {
			print("ERROR: Could not initialize database. Error: \(error.localizedDescription)")
			fatalError("TODO: handle DB init error with an informative app halt")
		}
		
		Task {
			do {
				async let queriedWidgets:[Widget] = Self.populateThenReadWidets()
				async let queriedFidgets:[Fidget] = Self.populateThenReadFidgets()
				
				// query
				// NOTE:
//				let _ = try await insertedWidgets
//				let _ = try await insertedFidgets
//				async let queriedWidgets:[Widget] = Self.readWidgets()
//				async let queriedFidgets:[Fidget] = Self.readFidgets()
				print("# queried widgets: \(try await queriedWidgets.count)")
				print("# queried fidgets: \(try await queriedFidgets.count)")
				
			} catch {
				print("ERROR: Could not populate database. Error: \(error.localizedDescription)")
			}
		}
	}
	
	
	//
	// MARK: -operations
	//
	
	private static func populateThenReadWidets() async throws -> [Widget] {
		let _ = try await AppDatabase.shared.writer.write { (database:Database) in
			try stride(from: 0, to: 10000, by: 1).map { (_:Int) in
				let widget = Widget.makeRandom()
				try widget.upsert(database)
				return widget
//				try Widget.makeRandom().inserted(database)
			}
		}
		
		return try await AppDatabase.shared.reader.read { (database:Database) in
			try Widget.fetchAll( database )
		}
	}
	
	
	private static func populateThenReadFidgets() async throws -> [Fidget] {
		let _ = try await AppDatabase.shared.writer.write { (database:Database) in
			try stride(from: 0, to: 10000, by: 1).map { (_:Int) in
				let fidget = Fidget.makeRandom()
				try fidget.upsert(database)
				return fidget
//				try Fidget.makeRandom().inserted(database)
			}
		}
	
	 	return try await AppDatabase.shared.reader.read { (database:Database) in
			try Fidget.fetchAll( database )
		}
	}


	//
	// MARK: -views
	//
	
	var body:some Scene {
		WindowGroup {
			ContentView()
				.environment(\.appDatabase, AppDatabase.shared)
		}
	}
}


// REF: https://github.com/groue/GRDB.swift/blob/master/Documentation/DemoApps/GRDBCombineDemo/GRDBCombineDemo/Persistence.swift
// MARK: - Give SwiftUI access to the database
//
// Define a new environment key that grants access to an AppDatabase.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.

private struct AppDatabaseKey : EnvironmentKey {
	static var defaultValue:AppDatabase { AppDatabase.DEBUG_designTimeDatabase()  }
}

extension EnvironmentValues {
	var appDatabase:AppDatabase {
		get { self[AppDatabaseKey.self] }
		set { self[AppDatabaseKey.self] = newValue }
	}
}

// In this demo app, views observe the database with the @Query property
// wrapper, defined in the GRDBQuery package. Its documentation recommends to
// define a dedicated initializer for `appDatabase` access, so we comply:

//extension Query where Request.DatabaseContext == AppDatabase {
//	/// Convenience initializer for requests that feed from `AppDatabase`.
//	init(_ request: Request) {
//		self.init(request, in: \.appDatabase)
//	}
//}
