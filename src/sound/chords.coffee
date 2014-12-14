###
Muse chord parser
Copyright (c) 2014 Anthony Bau
MIT License.
###

# # Chord
# Simple wrapper struct for a chord
exports.Chord = class Chord
  constructor: (name) ->
    [name, @base] = name.split '/'
    [@root, @quality] = CHORD_NAMES[name]
    @base ?= @root
    @trueName = @root + @quality

  toBits: ->
    return (if chord is @trueName then 1 else 0 for chord in CHORDS)

# # Static Information
# Declarative information about chord
# nomenclature
names = {
  notes: {
    'A': ['A']
    'Bb': ['A#', 'Bb']
    'B': ['B', 'Cb']
    'C': ['C', 'B#']
    'Db': ['C#', 'Db']
    'D': ['D']
    'Eb': ['D#', 'Eb']
    'E': ['E', 'Fb']
    'F': ['F', 'E#']
    'Gb': ['F#', 'Gb']
    'G': ['G']
    'Ab': ['Ab']
  },
  qualities: {
    'maj': ['maj', 'M', '']
    'maj7': ['maj7', 'ma7']
    'maj9': ['maj9']
    'maj13': ['maj13']
    '6': ['6', 'add6', 'add13']
    '6/9': ['6/9, 69']
    'maj#4': ['maj#4']
    'maj7b6': ['maj7b6', 'ma7b6', 'M7b6']
    '7': ['7', 'dom', 'dom7']
    '9': ['9']
    '13': ['13']
    '7#4': ['7#4', '7#11']
    '7b9': ['7b9']
    '7#9': ['7#9']
    'alt7': ['alt7']
    'sus4': ['sus4']
    'sus2': ['sus2']
    '7sus4': ['7sus4']
    '11': ['11', 'sus']
    'b9sus': ['b9sus', 'phryg']
    'min': ['min', 'm', '-']
    'min7': ['mi7', 'min7', 'm7', '-7']
    'm/maj7': ['m/ma7', 'm/maj7', 'mM7', 'm/M7']
    'm6': ['m6']
    'm11': ['m11']
    'm13': ['m13']
    'dim': ['dim']
    'dim7': ['dim7']
    'm7b5': ['m7b5']
    '5': ['5']
    'aug': ['aug', '+']
    '7#5': ['7#5', 'maj7+5']
  }
}

# Rearrange to generate all the chords
# and all their aliases
exports.CHORD_NAMES = CHORD_NAMES = {}
exports.CHORDS = CHORDS = []

# For every combination of actual root note
# and actual quality, add all their aliases
# to the maps
for trueNote, noteAliases of names.notes
  for trueQuality, qualityAliases of names.qualities
    actual = [trueNote, trueQuality]

    # Iterate over pairs of aliases
    for noteAlias in noteAliases
      for qualityAlias in qualityAliases
        CHORD_NAMES[noteAlias + qualityAlias] = actual

    # Also record all possible actual chords,
    # to use as the alphabet in training
    CHORDS.push actual
