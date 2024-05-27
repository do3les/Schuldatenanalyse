import QtQuick
import QtQuick.LocalStorage
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

/*
  Project Goals:

  + Aufgaben:

    a) Gesucht ist eine Namensliste (Rufname und Familiennamen) aller Schüler/innen in der Klasse 5b.
    b) Wie viele Schüler/innen besuchen die Klasse 7a?
    c) In welche Klasse geht die Schülerin Kimberly Russell?
    d) Welche Schülerin/welcher Schüler ist Klassensprecher/in in der Klasse 9b?
    e) Welche Lehrkräfte haben Lehrbefähigung für das Fach Mathematik?
    f) Welche Lehrkräfte (Rufname, Familienname) unterrichten die Klasse 6a?
    g) Ergänze die Liste aus f) um das jeweils unterrichtete Fach.
    h) Welche Noten hat der Schüler Jason Carpenter im Fach Englisch erzielt?
    i) Erstelle eine Notenliste (Rufname, Familienname, Note) für die 2. Ex im Fach Biologie in der Klasse 8b.
    k) Bestimme den Notendurchschnitt der unter i) genannten Ex.


  + Antworten darstellen:

    a) Liste mit zwei Spalten
    b) int (string)
    c) string
    d) string oder Liste mit zwei Spalten
    e) Liste mit zwei Spalten
    f) Liste mit zwei Spalten
    g) Liste mit drei Spalten
    h) int (string)
    i) Liste mit drei Spalten
    k) float (string)





    Anfangsidee war, QSqlQueryModel zu nutzen. Das aus C++ in QML nutzbar zu machen ist mit meinen C++ kentnissen nicht zu schaffen.
        Hier (https://wiki.qt.io/How_to_Use_a_QSqlQueryModel_in_QML) wird die Vorgehensweise beschrieben, und hier (https://gist.github.com/cckwes/18011569ae8440e91119)
        noch etwas praktischer umgesetzt, aber keines von beiden ließ sich auch nach längerem debugging bei mir zum laufen bringen. Ich glaube beide sind für Qt3 oder Qt4 ausgelegt.

    Danach hatte ich die Idee, stattdessen mit JS ein TableModel dynamisch zu erstellen, indem ich abfrage, welche Spalten gebraucht werden, und die in den String zum erstellen einfüge.
    Das würde glaube ich sogar gut funktionieren. Der Code für ein per String erstelltes TableView mit TableModel ist unten noch auskommentiert vorhanden.

    Eigentlich hätte ich erstmal die Aufgaben komplett durchlesen sollen. Hier reicht es, wenn ich eine Liste mit drei Spalten erstelle, und möglicherweise nur Teile davon nutze.
    Ich hatte am Anfang die Aufgaben nur überflogen, und es sah so aus, als würde ich viele verschiedene Ausgabeformate brauchen, daher die dynamischen Tabellen.


*/

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




    ColumnLayout {
        id: layout_root
        width: parent.width

        Rectangle {
            width: parent.width
            border.width: 1
            height: 30
            TextEdit {
                height: parent.height
                id: query_input
                width: parent.width
                text: "SELECT rufname AS col0, familienname AS col1, CAST(geburtsdatum AS text) AS col2 FROM lehrkraft"
            }
        }
        Button {
            text: "Run Query"
            id: query_button

            onClicked: {
                output_view_model.clear()

                console.log("Running query: " + query_input.text)

                createDB.getDBHandle().readTransaction(
                    function(tx){
                        let result = tx.executeSql(query_input.text) //Who cares about SQL injections anyways.

                        for(let i = 0; i < result.rows.length; i++){
                            output_view_model.append(
                                    result.rows.item(i)
                            )
                            console.log(result.rows.item(i))
                        }
                    }
                )
            }
        }
        ComboBox {
            id: aufgabenSelector
            currentIndex: 0

            model: ListModel {
                id: aufgabenSelectorModel
                ListElement {name: "-"; query: ""}

                ListElement {name: "a)"; query: "SELECT rufname AS col0, familienname AS col1 FROM schuelerin, klasse WHERE schuelerin.klasse_id = klasse.id AND klasse.name = '5b'"}
                ListElement {name: "b)"; query: "SELECT CAST(count(*) AS text) AS col0 FROM schuelerin, klasse WHERE schuelerin.klasse_id = klasse.id AND klasse.name = '7a'"}
                ListElement {name: "c)"; query: "SELECT klasse.name AS col0 FROM schuelerin, klasse WHERE schuelerin.klasse_id = klasse.id AND schuelerin.familienname = 'Russell' AND schuelerin.rufname = 'Kimberly'"}
                ListElement {name: "d)"; query: "SELECT rufname AS col0, familienname AS col1 FROM schuelerin, klasse WHERE schuelerin.klasse_id = klasse.id AND klasse.name = '9b' AND schuelerin.ist_klassensprecher = 1"}
                ListElement {name: "e)"; query: "SELECT rufname AS col0, familienname AS col1 FROM lehrkraft, lehrbefaehigung, fach WHERE fach.name = 'Mathematik' AND lehrbefaehigung.fach_id = fach.id AND lehrbefaehigung.lehrkraft_id = lehrkraft.id"}
                ListElement {name: "f)"; query: "SELECT DISTINCT rufname AS col0, familienname AS col1 FROM lehrkraft, unterrichtet, klasse WHERE klasse.name = '6a' AND unterrichtet.klasse_id = klasse.id AND unterrichtet.lehrkraft_id = lehrkraft.id"}
                ListElement {name: "g)"; query: "SELECT rufname AS col0, familienname AS col1, fach.name AS col2 FROM lehrkraft, unterrichtet, klasse, fach WHERE unterrichtet.lehrkraft_id = lehrkraft.id AND unterrichtet.klasse_id = klasse.id AND unterrichtet.fach_id = fach.id AND klasse.name = '6a'"}
                ListElement {name: "h)"; query: "SELECT CAST(wert AS text) AS col0 FROM schuelerin, note, fach WHERE fach.name = 'Englisch' AND schuelerin.rufname = 'Jason' AND schuelerin.familienname = 'Carpenter' AND note.schueler_id = schuelerin.id AND note.fach_id = fach.id"}
                ListElement {name: "i)"; query: "SELECT rufname AS col0, familienname AS col1, wert AS col2 FROM schuelerin, pruefung, note, klasse, fach WHERE pruefung.klasse = klasse.id AND pruefung.fach_id = fach.id AND note.pruefung_id = pruefung.id AND note.schueler_id = schuelerin.id AND fach.name = 'Biologie' AND klasse.name = '8b' AND pruefung.laufende_nr = 2"}
                // ListElement {name: "j)"; query: ""} j) fehlt?
                ListElement {name: "k)"; query: "SELECT CAST(avg(wert) AS text) AS col0 FROM schuelerin, pruefung, note, klasse, fach WHERE pruefung.klasse = klasse.id AND pruefung.fach_id = fach.id AND note.pruefung_id = pruefung.id AND note.schueler_id = schuelerin.id AND fach.name = 'Biologie' AND klasse.name = '8b' AND pruefung.laufende_nr = 2"}
            }

            textRole: "name"

            onCurrentIndexChanged: query_input.text = aufgabenSelectorModel.get(currentIndex).query
        }


        ListView {
            id: output_view

            width: parent.width
            height: 200


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
                    width: parent.width / 3
                    text: col0
                }

                Text {
                    width: parent.width / 3
                    x: parent.width / 3
                    text: col1
                }

                Text {
                    width: parent.width / 3
                    x: 2 * parent.width / 3
                    text: col2
                }

            }

        }




//         TableView {
//             id: output_table

//             width: parent.width
//             height: 400


//             model: TableModel {
//                 TableModelColumn { display: "foo" }
//                 TableModelColumn { display: "bar" }

//                 rows: [
//                     {"foo": "1", "bar": "one"},
//                     {"foo": "2", "bar": "two"},
//                     {"foo": "3", "bar": "three"}
//                 ]
//             }

//             delegate: Rectangle {
//                 implicitWidth: 100
//                 implicitHeight: 30
//                 border.width: 1

//                 Text {
//                     text: display
//                     anchors.centerIn: parent
//                 }


//             }

//         }

//         RowLayout {
//             Button {
//                 id: dynTableCreator
//                 text: "New Table"
//                 onClicked: {
//                     const newTable = Qt.createQmlObject('
// import QtQuick
// import Qt.labs.qmlmodels

// TableView {
//     id: dynamic_table
//     width: parent.width
//     height: 200

//     model: TableModel {
//         id: dynamic_model
//         TableModelColumn { display: "alpha" }
//         TableModelColumn { display: "bravo" }

//         rows: [
//             {"alpha": "test", "bravo": "hi wrld!"},
//             {"alpha": "number 2", "bravo": "hello again!"}
//         ]
//     }
//     delegate: Rectangle {
//         id: dynamic_delegate
//         implicitWidth: 100
//         implicitHeight: 30
//         border.width: 1

//         Text {
//             text: display
//             anchors.centerIn: parent
//         }
//     }

// }
// ', layout_root, "myDynamicTable");
//                     console.log("Created new Table");
//                     // newTable.destroy(3000);
//                 }
//             }

//             Button {
//                 text: "Remove dynamic table"

//                 onClicked: {
//                     //Hat nicht funktioniert.
//                     console.log("Destroyed table (WIP)")
//                 }
//             }

//         }

    }


    Component.onCompleted:{
        query_button.clicked()
        // createDB.create()
    }

}
