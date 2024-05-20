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

            let db=LocalStorage.openDatabaseSync("DB","1.1","database",10000)
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

    ListView {
        width: 300
        height: 200
        x:0
        y:100


        model: ListModel{
            id: my_Model
        }

        delegate: Rectangle {
            width: 200
            height: 20

            color: {
                if(index%2==0){
                        "grey"
                }
                else {
                    "darkgrey"
                }
            }

            Text {
                width:  parent.width/2
                id: my_delegate
                text: salutee
            }

            Text {
                width:  parent.width/2
                x: parent.width/2

                text: salutation
            }
        }
    }




    // Component.onCompleted:{

    //     createDB.create()
    // }

}
