//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  TenorSaxFingering Plugin
//
// This Program based on the Xaphoon Plugin of:
//  Copyright (C)2010 Nicolas Froment (lasconic)
//  Copyright (C)2015 Hervé Laurent (AirW)
//  Copyright (C)2019 Sylvain Kuntzmann (skunt)
//
// Edited by: 
//  Copyright (C)2019 Sepp Knieriem(Seppel0815)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

     
     import QtQuick 2.9
     import MuseScore 3.0

MuseScore {
    version: "3.0"
    description: "This plugin displays fingering for Tenor Sax"
    menuPath: "Plugins.TenorSax Fingering"

    property variant fingerings : [ "C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "H", "J", "j", "K", "k", "L", "M", "m", "N", "n", "O", "o", "Q", "R", "r", "B", "P"];

    onRun: {
        apply();
        Qt.quit();
    }

    function tabNotes(notes, cursor) {
        var pitch = notes[0].pitch;  // pitch of the chord top note
        var index = pitch - 46;      //  index =  pitch - 46 (60 is the midi pitch of B, 0 index in fingerings)
        if(index >= 0 && index < fingerings.length){
            var text = newElement(Element.STAFF_TEXT);
            text.text = '<font face="SeppsTenorSaxFont"/>' + '<font size="50"/>' + fingerings[index];
//            text.offsetY = -7,5; //not used : automatic placement
//            text.offsetX = -1,1; //not used : automatic placement
            cursor.add(text);
        }
    }

    function applyToSelection(func) {
        if (typeof curScore === 'undefined')
            Qt.quit();
        var cursor = curScore.newCursor();
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = false;
        cursor.rewind(1);
        if (!cursor.segment) { // no selection
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff  = curScore.nstaves - 1; // and end with last
        } else {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick == 0) {
                // this happens when the selection includes
                // the last measure of the score.
                // rewind(2) goes behind the last segment (where
                // there's none) and sets tick=0
                endTick = curScore.lastSegment.tick + 1;
            } else {
                endTick = cursor.tick;
            }
            endStaff   = cursor.staffIdx;
        }
        console.log(startStaff + " - " + endStaff + " - " + endTick)

        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1); // beginning of selection
                cursor.voice    = voice;
                cursor.staffIdx = staff;

                if (fullScore)  // no selection
                    cursor.rewind(0); // beginning of score
                    while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                        if (cursor.element && cursor.element.type == Element.CHORD) {
                            var graceChords = cursor.element.graceNotes;
                            for (var i = 0; i < graceChords.length; i++) {
                                // iterate through all grace chords
                                var notes = graceChords[i].notes;
                                func(notes, cursor);
                            }
                            var notes = cursor.element.notes;
                            func(notes, cursor);
                        } // end if CHORD
                        cursor.next();
                    } // end while segment
            } // end for voice
        } // end for staff
        Qt.quit();
    } // end applyToSelection()

    function apply() {
        applyToSelection(tabNotes)
    }

}
