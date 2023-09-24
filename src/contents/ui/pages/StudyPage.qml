import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.Controls.Styles 1.4 as Style
import "Components"

Kirigami.Page{
    id:root
    property Database database

    property string wordName:""
    property string wordContext:""
    property string wordSource:""

    property int wordId:0

    property int cardId:0

    title:"Study"

    property Controls.StackView stackView: Controls.StackView.view




    titleDelegate: RowLayout{
		Controls.Button{
			icon.name: "arrow-left"
            visible: stackView !== null
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


    function selectRandomCard(){
        database.getRandomWord(cardId,(w)=>{
            wordName = w.name
            wordContext = w.context
            wordSource = w.source
            learningProgressBar.value = w.progress * 0.01

            wordId= w.id
        })
    }


    Component.onCompleted:{
        selectRandomCard()
    }



    WordView{
        id:wordView
        anchors.fill:parent
        name:wordName
        context:wordContext
        source:wordSource
    }


    Controls.Label{
        text:"Learning Progress"
        anchors{
            leftMargin:4
            left: learningProgressBar.left
            bottom: learningProgressBar.top
        }
    }
    Controls.ProgressBar{
        id:learningProgressBar
        anchors{
            horizontalCenter: parent.horizontalCenter
            bottom: buttonsLayout.top
            bottomMargin:34

        }
    }

    RowLayout{
        id:buttonsLayout
        anchors{
            bottom: parent.bottom
            right:parent.right
            left:parent.left

        }
        Controls.Button{
            text:"I forgot"
            palette {
                button: Kirigami.Theme.negativeBackgroundColor
            }
            onClicked:{
                database.addWordProgress(wordId, -15,()=>{
                    selectRandomCard()
                })
            }
        }
        Controls.Button{
            text:"I know it"
            Layout.fillWidth:true

            palette {
                button: Kirigami.Theme.positiveBackgroundColor
            }
            onClicked:{
                database.addWordProgress(wordId, 5, ()=>{
                    selectRandomCard()
                })
            }
        }
    }
}
