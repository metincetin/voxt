import QtQuick 2.15
import QtQuick.LocalStorage 2.0

Item{
	// reference to the database object
    property var db

	signal initialized();

    function initDatabase(callback) {
		print('Initializing Database')
		db = LocalStorage.openDatabaseSync("voxt", "1.0", "", 100000)
		db.transaction( function(tx) {
			print('... create table')
			tx.executeSql('CREATE TABLE IF NOT EXISTS words(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, context TEXT, source TEXT, cardID int NOT NULL, progress INTEGER DEFAULT 0)')
			tx.executeSql('CREATE TABLE IF NOT EXISTS cards(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)')
			callback();
		})
	}

    function storeData() {
        // stores data to DB
    }

    function readCards(callback) {
		db.transaction(function(tx){
			var results = tx.executeSql("SELECT * FROM cards")
			var countResults = tx.executeSql(`SELECT c.id AS id, COUNT(w.id) AS value
				FROM cards c
				LEFT JOIN words w ON c.id = w.cardID
				GROUP BY c.id
			`)
			callback({"data":results.rows, "count": countResults.rows})
		})
	}
	function updateCard(cardId, name, callback){
		db.transaction(function (tx){
			tx.executeSql(`UPDATE cards SET name="${name}" where id=${cardId}`)
			callback()
		})
	}

	function readWords(cardId, callback) {
		db.transaction(function(tx){
			var results = tx.executeSql(`SELECT * FROM words WHERE cardId=${cardId}`)
			callback(results.rows)
		})
	}

	function getWord(wordID, callback){
		db.transaction(function(tx){
			var results = tx.executeSql(`SELECT * FROM words WHERE id=${wordID}`)
			callback(results.rows[0])
		})
	}
	function deleteCard(cardId){
		db.transaction(function(tx){
			tx.executeSql(`DELETE FROM cards where id=${cardId}`)
			tx.executeSql(`DELETE FROM words where cardId=${cardId}`)
		})
	}
	function getRandomWord(cardId, callback){
		db.transaction(function(tx){
			var res = tx.executeSql(`SELECT * FROM words where cardId=${cardId} ORDER BY RANDOM() LIMIT 1`)
			callback(res.rows[0])
		})
	}
	function addWordProgress(wordId, progress, callback){
		db.transaction(function(tx){
			var res = tx.executeSql(`UPDATE words SET progress = CASE WHEN progress + ${progress} < 0 THEN 0 ELSE progress+${progress} END WHERE id=${wordId}`)
			callback()
		})
	}

	function putCard(name, callback){
		db.transaction(function(tx){
			tx.executeSql(`INSERT INTO cards (name) VALUES (?)`, [name])
			callback()

		})
	}

	function putWord(data){
		db.transaction(function (tx){
			tx.executeSql("INSERT INTO words (name, context, source, cardID) VALUES (?,?,?,?)", [data.name, data.context, data.source, data.cardId	])
		})
	}

    Component.onCompleted: {
        initDatabase(function(){initialized()})
    }

    Component.onDestruction: {
        storeData()
    }
}
