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
				try await Self.populateDatabase()
			} catch {
				print("ERROR: Could not populate database. Error: \(error.localizedDescription)")
			}
		}
	}
	
	
	//
	// MARK: -operations
	//
	
	private static func populateDatabase() async throws {
		// populate
		let widgets:[Widget] = try await AppDatabase.shared.writer.write { (database:Database) in
			try stride(from: 1, to: 100, by: 1).map { (_:Int) in
				try Widget.makeRandom().inserted(database)
			}
		}
		
		// TODO
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
