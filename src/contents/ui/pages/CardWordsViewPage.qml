import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import "Components"
import QtLocation 5.6

Kirigami.Page{
	id: root

	property string name: "Card"
	property int cardId: 0

	property Database database

	property Controls.StackView stackView: Controls.StackView.view

	property alias model: listModel

	property real totalProgress:0

	title: name

	Component.onCompleted:{
		listModel.clear()
		database.readWords(cardId, function(words){
			var progressSum = 0
			for (var i = 0;i<words.length;i++){
				var data = words[i]

				listModel.append({"name": data.name, "context": data.context, "source":  data.source, "progress": data.progress})
				progressSum += data.progress
			}
			if (words.length > 0)
				totalProgress = progressSum / words.length
		})
	}


	signal wordOpenRequested(var word)

	titleDelegate: RowLayout{
		Controls.Button{
			icon.name: "arrow-left"
			flat:true
			onClicked:{
				stackView.pop()
			}
		}
		Kirigami.Heading{
			id:title
			text:root.title
		}
	}

	ListModel{
		id: listModel
	}


	actions{
		right: Kirigami.Action {
			icon.name: "bqm-add"
			tooltip:"New Word"
			onTriggered: {
				newWordSheet.open()
			}
		}
	}

	ColumnLayout{
		anchors.fill: parent
		Controls.Label{
			text:`Total words: ${listModel.count}`
		}
		Controls.Label{
			text:`Total progress: ${parseInt(totalProgress)}%`
			leftPadding:32
		}

		Rectangle{
			color:Kirigami.Theme.alternateBackgroundColor
			Layout.fillWidth: true
			Layout.fillHeight:true


			Controls.TextField{
				id: searchBox
				anchors{
					left:parent.left
					right:parent.right
					top:parent.top
				}
				placeholderText: "Search"
			}

			ListView{
				id: view
				model: listModel
				anchors{
					top:searchBox.bottom
					left:parent.left
					right:parent.right
					bottom:parent.bottom
				}

				clip:true



				highlightMoveDuration: 50
				delegate:Item{
					visible: searchBox.text == "" || (searchBox.text != "" && name.includes(searchBox.text))
					width: view.width
					height:visible ? 40 : 0
					RowLayout{
						anchors.fill:parent
						anchors.leftMargin:8
						anchors.rightMargin:8
						Controls.Label{
							text: name
							Layout.fillWidth:true
						}
						Controls.ProgressBar{
							value: progress / 100
						}

					}

					MouseArea {
						anchors.fill: parent
						onClicked: view.currentIndex = index
						onDoubleClicked:{
							wordOpenRequested(listModel.get(index))
						}
					}
				}

				highlight:Rectangle{
					color:Kirigami.Theme.highlightColor
				}

				focus:true
			}
		}
	}

	Kirigami.OverlaySheet{
		id: newWordSheet
		header: Kirigami.Heading{
				text:"New Word"
		}

		ColumnLayout{
			Controls.TextField{
				id: newWordName
				placeholderText: "Word"
			}

			Controls.TextField{
				id: introducedContext
				placeholderText: "Introduced context"
			}

			Controls.TextField{
				id: newWordSource
				placeholderText: "Source"
			}

			ListView{
				model:ListModel{}
				delegate:Controls.TextField{
				}

			}

			Controls.Button{
				text:"Add"
				icon.name:"bqm-add"
				onClicked:{
					newWordSheet.close()
					model.append({"name": newWordName.text, "context":introducedContext.text, "source": newWordSource.text})
					database.putWord({"cardId": cardId, "name": newWordName.text, "context": introducedContext.text, "source": newWordSource.text})
				}
			}
		}
	}
}
