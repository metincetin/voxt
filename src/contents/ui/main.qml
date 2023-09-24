import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import QtQuick.LocalStorage 2.0
import "Components"

Kirigami.ApplicationWindow {
    id: root


    Database{
        id:database
        onInitialized:{
            readDatabase()
        }
    }


    function readDatabase(){
        database.readCards(function(x){
            for(var i = 0;i<x.data.length;i++){
                var name = x.data[i].name
                var id = x.data[i].id

                var count = 0;

                for(var j = 0;j<x.count.length;j++){
                    var d = x.count[j]
                    if (d.id === id){
                        count = d.value;
                        break;
                    }
                }

                var data = {"id": id, "name":name, "count": count}

                if (cardModel.count >= i){
                    cardModel.set(i, data)
                } else {
                    print("NEW CARD")
                    cardModel.append(data)
                }
            }
        })
    }


    Controls.StackView{
        id:stack
        anchors.fill:parent

        ListModel{
            id:cardModel
        }


        initialItem:Kirigami.ScrollablePage {
            title:"Your Cards"

            actions.right:Kirigami.Action{
                icon.name:"bqm-add"
                tooltip:"New Card"
                onTriggered:{
                   newCardSheet.open()
                }
            }

            Controls.StackView.onActivated: readDatabase()



            GridLayout{
                columns: Kirigami.Settings.isMobile ? 1 : 2
                anchors.centerIn: parent
                Controls.Label{
                    id:noCardLabel
                    visible: cardModel.count == 0
                    text:"You haven't created any cards"
                    anchors.centerIn: parent
                }
                Controls.Button{
                    visible: cardModel.count == 0
                    anchors{
                        top: noCardLabel.bottom
                        topMargin:8
                        horizontalCenter: noCardLabel.horizontalCenter
                    }
                    text:"Create"
                    icon.name:"bqm-add"
                    onClicked:{
                        newCardSheet.open()
                    }
                }
                Repeater{
                    model:cardModel


                    Kirigami.Card{

                        actions:[
                            Kirigami.Action{
                                enabled: count > 0
                                text:"Study"
                                icon.name:"accessories-dictionary-symbolic"
                                onTriggered:{
                                    stack.push(studyPage, {"database": database, "cardId": id})
                                }
                            },
                            Kirigami.Action{
                                text:"Edit"
                                icon.name:"edit-entry"
                                onTriggered:{
                                    editCardSheet.cardId = id
                                    editCardSheet.cardName = name
                                    editCardSheet.open()
                                }

                            },
                            Kirigami.Action{
                                id:showAction
                                text:"Details"
                                icon.name:"view-list-details"
                                onTriggered:{
                                    stack.push(cardWordsViewPage, {"name": name, "cardId": id, "database": database})
                                }
                            },
                            Kirigami.Action{
                                text:"Delete"
                                icon.name:"delete"

                                onTriggered:{
                                    deleteCardPrompt.cardId = id
                                    deleteCardPrompt.open()

                                }
                            }
                        ]

                        Layout.preferredWidth: Kirigami.Settings.isMobile? parent.width : 200
                        Layout.preferredHeight: 140

                        // for some reason, Heading itself doesn't do left margin
                        // and top
                        header:RowLayout{
                                Kirigami.Heading{
                                    text:name
                                    Layout.leftMargin: 8
                                    Layout.topMargin: 8
                            }
                        }
                        contentItem: Controls.Label{
                            text:(function(){
                                if (count === 0) return "0 word";
                                if (count === 1) return "1 word";
                                return `${count} words`
                            })();

                            MouseArea{
                                anchors.fill:parent
                                onClicked:{
                                    showAction.trigger()
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    Component{
        id: cardWordsViewPage

        CardWordsViewPage{
			onWordOpenRequested: (w) => {
				stack.push(wordViewPage, {"name": w.name, "context":w.context, "source":w.source})
			}
        }
    }

    Component{
		id:wordViewPage
        WordViewPage{
            id: page
        }
    }
    Component{
        id:studyPage
        StudyPage{

        }
    }
    Component {
        id: aboutPage
        Kirigami.AboutPage {
            aboutData: About
        }
    }

    Kirigami.OverlaySheet{
        id:editCardSheet
        property string cardName: ""
        property int cardId: 0

        header: Kirigami.Heading{
            text:`Edit "${editCardSheet.cardName}"`
        }
        ColumnLayout{
            Controls.TextField{
				id: editCardName
				text: editCardSheet.cardName
			}

			Controls.Button{
				text:"Update"
				icon.name:"edit-entry"
				onClicked:{
					editCardSheet.close()
					database.updateCard(editCardSheet.cardId, editCardName.text, () => readDatabase())
                }
			}
        }
    }

    Kirigami.OverlaySheet{
		id: newCardSheet
		header: Kirigami.Heading{
				text:"New Card"
		}

		ColumnLayout{
			Controls.TextField{
				id: newCardName
				placeholderText: "Name"
			}

			Controls.Button{
				text:"Add"
				icon.name:"bqm-add"
				onClicked:{
					newCardSheet.close()
					database.putCard(newCardName.text, () => readDatabase())
				}
			}
		}
	}

    Kirigami.PromptDialog{
		id: deleteCardPrompt
		property int cardId: 0
		title: "Delete Card"
        subtitle:"Are you sure you want to delete this card? This can't be reverted."
        standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No

        onAccepted: {
            database.deleteCard(cardId)
            cardModel.clear()
            readDatabase()
        }

	}
}

