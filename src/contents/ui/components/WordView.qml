import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item{
    id:root
    property string name: "Word"
    property string context: "This is the context that the learner was introduced"
    property string source: "Source of the context, where did you find this word?"

    property Controls.StackView stackView: Controls.StackView.view

    Controls.Label{
        id:wordLabel
        anchors.top: parent.top
        anchors.horizontalCenter:parent.horizontalCenter
        width:root.width
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter

        font.pointSize: 64

        text:name
    }
    Controls.Label{
        id:wordContext
        text:context
        anchors.horizontalCenter:wordLabel.horizontalCenter
        anchors.top:wordLabel.bottom
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        width:300
    }

    Controls.Label{
        text:source
        font.bold:true
        anchors.horizontalCenter: wordContext.horizontalCenter
        anchors.top: wordContext.bottom
    }

}

