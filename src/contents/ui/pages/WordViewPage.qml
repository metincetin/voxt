import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "Components"

Kirigami.Page {
    id:root
    property alias name: wordView.name
    property alias context: wordView.context
    property alias source: wordView.source

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

	actions.contextualActions:[
        Kirigami.Action{
            icon.name:"edit-entry"
            text: "Edit"
        },
        Kirigami.Action{
            icon.name:"delete"
        }
    ]

    WordView{
        id:wordView
        anchors.fill:parent
    }
}

