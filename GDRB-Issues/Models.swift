//
//  Models.swift
//  GDRB-Issues
//
//  Created by Marcel Bradea on 2023-11-27.
//

import Foundation
import GRDB


struct Widget : FetchableRecord, PersistableRecord, Identifiable, Codable {

	//
	// MARK: - constants -
	//

	private(set) static var databaseTableName:String = "Widgets"
	

	//
	// MARK: - state -
	//
	
	let id:String
	let bing:String
	let ding:String
	let ring:String
	
	
	//
	// MARK: - implementations -
	//

	func encode( to container:inout PersistenceContainer ) throws {
		container[Columns.id] = id
		container[Columns.bing] = bing
		container[Columns.ding] = ding
		container[Columns.ring] = ring
	}
	
	
	static func makeRandom() -> Widget {
		return Widget(id: _getRandomValue(), bing: _getRandomValue(), ding: _getRandomValue(), ring: _getRandomValue())
		
		
		func _getRandomValue() -> String {
			UUID().uuidString
		}
	}
	

	//
	// MARK: - outer structures -
	//

	enum Columns : String, ColumnExpression, CodingKey {
		case
			id,
			bing,
			ding,
			ring
	}
	
}



struct Fidget : FetchableRecord, PersistableRecord, Identifiable, Codable {

	//
	// MARK: constants
	//

	private(set) static var databaseTableName:String = "Fidgets"
	

	//
	// MARK: - state -
	//
	
	let id:String
	let bing:String
	let ding:String
	let ring:String
	
	
	//
	// MARK: - implementations -
	//

	func encode( to container:inout PersistenceContainer ) throws {
		container[Columns.id] = id
		container[Columns.bing] = bing
		container[Columns.ding] = ding
		container[Columns.ring] = ring
	}
	
	
	static func makeRandom() -> Fidget {
		return Fidget(id: _getRandomValue(), bing: _getRandomValue(), ding: _getRandomValue(), ring: _getRandomValue())
		
		
		func _getRandomValue() -> String {
			UUID().uuidString
		}
	}
	

	//
	// MARK: - outer structures -
	//

	enum Columns : String, ColumnExpression, CodingKey {
		case
			id,
			bing,
			ding,
			ring
	}
	
}
