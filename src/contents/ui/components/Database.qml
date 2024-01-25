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
			tx.executeSql('CREATE TABLE IF NOT EXISTS words(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, context TEXT, source TEXT, created DATE, cardID int NOT NULL, progress INTEGER DEFAULT 0)')
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
			tx.executeSql("INSERT INTO words (name, context, source, created, cardID) VALUES (?,?,?, DATE('now'),?)", [data.name, data.context, data.source, data.cardId])
		})
	}

	function toJson(callback){
		db.transaction(function(tx){
			var cards = tx.executeSql("SELECT * FROM cards").rows
			var words = tx.executeSql("SELECT * FROM words").rows

			var cardOut = []
			var wordOut = []


			for(var i = 0;i<cards.length;i++){
				cardOut.push(cards[i])
			}
			for(var i = 0;i<words.length;i++){
				wordOut.push(words[i])
			}

			console.log(JSON.stringify({"cards": cardOut, "words":wordOut}))

			callback(JSON.stringify({"cards": cardOut, "words":wordOut}))

		})
	}
	function tryImportData(jsonString, override, callback){
		console.log(override)
		try{
			db.transaction(function (tx){
				if (override){
					tx.executeSql("DELETE FROM words")
					tx.executeSql("DELETE FROM cards")
				}

				var js = JSON.parse(jsonString)

				js.cards.forEach(function (data){
					console.log(JSON.stringify(data))
					tx.executeSql(`INSERT OR REPLACE INTO cards (id, name) VALUES (?, ?)`, [data.id, data.name])
				})

				js.words.forEach(function (data){
					console.log([data.id, data.name, data.context, data.source, data.created, data.cardID])
					tx.executeSql("INSERT OR REPLACE INTO words (id, name, context, progress, source, created, cardID) VALUES (?, ?, ?,?,?, ?,?)", [data.id, data.name, data.context, data.progress, data.source, data.created, data.cardID])
				})

				callback({error:false})
			})
		}catch(e){
			callback({error:true, message: e})
		}
	}

    Component.onCompleted: {
        initDatabase(function(){initialized()})
    }

    Component.onDestruction: {
        storeData()
    }
}
