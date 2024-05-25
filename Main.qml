import QtQuick
import QtQuick.LocalStorage
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

Window {
    width: 1280
    height: 960
    visible: true
    title: qsTr("Schuldatenanalysetool")

    Item{

        id: createDB

        function create(){
            console.log("----- ERROR ----- \n Creating database. THIS SHOULD NEVER HAPPEN, THE DATABASE SHOULD BE GIVEN!")
            let db=LocalStorage.openDatabaseSync("DB","1.1","database",10000)

            db.transaction(
                function(tx){
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Greetings(salutation TEXT, salutee TEXT)')
                }

            )

        }

        function getDBHandle(){

            let db=LocalStorage.openDatabaseSync("DB","1.1","database",1000000)
            return db


        }


    }


    RowLayout {
        TextEdit {
            id: query_input
            width: 500
            text: "SELECT * FROM fach"

        }
        Button {
            text: "Run Query"

            onClicked: {
                // output_view_model.clear()

                console.log("Running query: " + query_input.text)

                createDB.getDBHandle().readTransaction(
                    function(tx){
                        let result = tx.executeSql(query_input.text) //Who cares about SQL injections anyways.

                        for(let i = 0; i < result.rows.length; i++){
                            output_view_model.append(
                                {foo: result.rows.item(i).name, bar: result.rows.item(i).kuerzel}
                            )
                        }
                    }
                )
            }
        }
    }


    ListView {
        id: output_view

        width: parent.width
        height: 50
        x: 0
        y: 100

        model: ListModel {
            id: output_view_model
        }

        delegate: Rectangle {
            width: parent.width
            height: 20

            color: {
                if(index%2==0){
                    "lightgrey"
                }else {
                    "lightgreen"
                }
            }

            Text {
                width: parent.width / 2
                text: foo
            }

            Text {
                width: parent.width / 2
                x: parent.width / 2
                text: bar
            }

        }

    }


    TableView {
        id: output_table

        width: parent.width
        height: 400
        x: 0
        y: 300

        model: TableModel {
            TableModelColumn { display: "foo" }
            TableModelColumn { display: "bar" }

            rows: [
                {"foo": "1", "bar": "one"},
                {"foo": "2", "bar": "two"},
                {"foo": "3", "bar": "three"}
            ]
        }

        delegate: Rectangle {
            implicitWidth: 100
            implicitHeight: 30
            border.width: 1

            Text {
                text: display
                anchors.centerIn: parent
            }
        }

    }




    // Component.onCompleted:{

    //     createDB.create()
    // }

}
