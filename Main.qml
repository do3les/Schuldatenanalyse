import QtQuick
import QtQuick.LocalStorage
import QtQuick.Layouts
import QtQuick.Controls

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

    // RowLayout {

    //     Label {
    //         text: "salutation"
    //         color: "black"
    //     }

    //     TextEdit {
    //         id: salutationText
    //         width: 100
    //     }

    //     Label {
    //         text: "salutee"
    //         color: "black"
    //     }

    //     TextEdit {
    //         id: saluteeText
    //         width: 100
    //     }

    //     Button {
    //         text: "insert"

    //         onClicked: {
    //             console.log("try insert")

    //             let db=createDB.getDBHandle()
    //             db.transaction(
    //                 function(tx){
    //                     console.log("Insert Transaction beginn...")
    //                     tx.executeSql("INSERT INTO Greetings (salutation, salutee) VALUES ('" + salutationText.text + "','" + saluteeText.text +"' )")

    //                 }
    //             )
    //         }

    //     }

    //     Button {
    //         text: "ShowData"

    //         onClicked: {
    //             my_Model.clear()

    //             console.log("show DB Data")

    //             //let db=createDB.getDBHandle()
    //             createDB.getDBHandle().transaction(
    //                 function(tx){
    //                     console.log("Getting Data ...")
    //                     let result=tx.executeSql("SELECT * FROM Greetings")
    //                     for ( let i = 0; i < result.rows.length; i++){
    //                         console.log(result.rows.item(i).salutee)
    //                         console.log(result.rows.item(i).salutation)

    //                         my_Model.append(
    //                             {salutee: result.rows.item(i).salutee, salutation: result.rows.item(i).salutation}
    //                         )

    //                     }

    //                 }
    //             )
    //         }

    //     }

    // }



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

                createDB.getDBHandle().transaction(
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
        height: 400
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




    // Component.onCompleted:{

    //     createDB.create()
    // }

}
