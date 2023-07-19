module IranianMusicKnowledgeBase

##########################################################################################
# Modules and Libraries
using Charm
using Chakra
using DataStructures
using MIDI
using Charm.Midi
using JSON

##########################################################################################
# Structural name types:
struct GusheName
    name::String
end

struct AvazName
    name::String
end

struct DastgahName
    name::String
end

struct RadifName
    name::String
end

##########################################################################################
# New types
struct IR_Pitch <: Charm.Pitch
    value::Float32
end
    Base.:<=(x::IR_Pitch,y::IR_Pitch)::Bool = x.value <= y.value
    struct IR_Interval <: Charm.Interval
    value::Float32
end



Base.:<=(x::IR_Pitch,y::IR_Pitch)::Bool = Chakra.Error(<=,x,y,Bool)
Base.:<=(x::IR_Interval,y::IR_Interval)::Bool = Chakra.Error(<=,x,y,Bool)

Charm.zero(::Type{<:IR_Interval})::IR_Interval = Chakra.Error(Charm.zero,T)

Base.:+(x::IR_Interval,y::IR_Interval)::IR_Interval = Chakra.Error(+,x,y,IR_Interval)
Base.:-(x::IR_Interval)::IR_Interval = Chakra.Error(-,x,IR_Interval)
Base.:-(x::IR_Interval,y::IR_Interval) = y + (-x)

diff(x::IR_Pitch,y::IR_Pitch)::IR_Interval = Chakra.Error(diff,x,y,IR_Interval)
shift(x::IR_Interval,y::IR_Pitch)::IR_Pitch = Charka.Error(shift,x,y,IR_Pitch)

Base.:-(x::IR_Interval,y::IR_Interval)::IR_Interval = y + (-x)
Base.:+(x::IR_Interval,y::IR_Pitch)::IR_Pitch = shift(x,t)
Base.:+(x::IR_Pitch,y::IR_Interval)::IR_Pitch = shift(y,x)
Base.:-(x::IR_Pitch,y::IR_Pitch)::IR_Interval = diff(x,y)

##########################################################################################
# Iranian intervals
Tanini = IR_Interval(2)
Baghie = IR_Interval(1)
Mojannab = IR_Interval(1.5)
Bish_Tanini = IR_Interval(2.5)
Tanini_plus_Baghie = IR_Interval(3)

##########################################################################################
# IDs
struct RadifId <: Chakra.Id
    RadifName::String
end

struct DastgahId <: Chakra.Id
    DastgahName::String
    RadifName::String
end

struct AvazId <: Chakra.Id
    AvazName::String
    DastgahName::String
    RadifName::String
end

struct GusheId <: Chakra.Id
    GusheName::String
    AvazName::String
    DastgahName::String
    RadifName::String
end

struct NoteId <: Chakra.Id
    NoteNumber::Int
    GusheName::String
    AvazName::String
    DastgahName::String
    RadifName::String
end

##########################################################################################
# Constituents
struct IR_Note <: Chakra.Constituent
    Id::NoteId
    pitch::IR_Pitch
    velocity::Int
    position::Charm.Midi.Time
    duration::Charm.Midi.Duration
end

struct Gushe <: Chakra.Constituent
    Id::GusheId
    Notes::Vector{IR_Note}
    Alternative_Note::Vector{Int}
    Temoin_Note::Int
    Arret_Note::Int
    Daramad::Bool
    Forud::Bool
    Modgardan::Vector{String}
    Rhythmic::Bool
    Melodic::Bool
    Repeated_in::Vector{String}
    Sadeghi_Importance::Int
end

struct Avaz <: Chakra.Constituent
    Id::AvazId
    Gushes::Vector{Gushe}
    Variable_Note::Int
    Temoin_Note::Int
    Arret_Note::Int
end

struct Dastgah <: Chakra.Constituent
    Id::DastgahId
    Avazes::Vector{Avaz}
    Dastgah_DomainـIntervals::Vector{IR_Interval}
end

struct Radif <: Chakra.Constituent
    Id::RadifId
    Dastgahs::Vector{Dastgah}
end

struct Modgardans <: Chakra.Constituent
    Radif::String
    Dastgah::String
    Avaz::String
    Modgardan_From::String
    Modgardan_To::Vector{String}
end

struct Repeated <: Chakra.Constituent
    Radif::String
    Dastgah::String
    Avaz::String
    Gushe::String
    Repeated_in::Vector{String}
end

struct Melodic <: Chakra.Constituent
    Radif::String
    Dastgah::String
    Avaz::String
    Name::String
end

struct Rhythmic <: Chakra.Constituent
    Radif::String
    Dastgah::String
    Avaz::String
    Name::String
end
##########################################################################################
# Hierarchies
struct IR_Hierarchy <: Chakra.Hierarchy
    radifs::Vector{Radif}
end

##########################################################################################
# Events
struct IR_Event
    pitch::IR_Pitch
    position::Charm.Midi.Time
    duration::Charm.Midi.Duration
    gushe::GusheName
    avaz::AvazName
    dastgah::DastgahName
    radif::RadifName
    Dastgah_DomainـIntervals::Vector{IR_Interval}
end

IR_Seq = Vector{IR_Event}

##########################################################################################
# Loading Data
function Get_Modified_Iranian_Attributes(track::MIDITrack,
                                         Song_tpq::Int16,
                                         Avazname::String)
    noteIndex = 1
    Events = track.events
    result = []
    counter = 0
    pitchBendDetector = 0
    pitchBendDetector2 = 0
    notes = getnotes(track, Song_tpq)
    for i in 1:length(Events)
        if typeof(Events[i]) == MIDI.PitchBendEvent
            counter = counter + 1
            if counter == 2
                pitchBendDetector = Events[i].pitch
                break
            end
        end
    end
    for i in range(1, length(Events))
        if typeof(Events[i]) != MIDI.ControlChangeEvent && typeof(Events[i]) != MIDI.ProgramChangeEvent && typeof(Events[i]) != MIDI.TrackNameEvent && typeof(Events[i]) != MIDI.TimeSignatureEvent
            if Avazname == "Dashty" || Avazname == "Abuata" || Avazname == "Afshari" || Avazname == "Bayat e Tork"  || Avazname == "Bayat e Kord" || Avazname == "Rast Panjgah" || Avazname == "Nava"
                if typeof(Events[i]) == MIDI.NoteOffEvent
                    if typeof(Events[i-1]) == MIDI.PitchBendEvent
                        if Events[i-1].pitch == pitchBendDetector
                            append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note - 0.5)])
                        else
                            append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note)])
                        end
                    else
                        append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note)])
                    end
                    if noteIndex < length(notes)
                        noteIndex = noteIndex + 1
                    end
                end
            elseif Avazname == "Homayoun" || Avazname == "Bayat e Esfahan" || Avazname == "Chahargah" || Avazname == "Segah"
                break
            else
                if typeof(Events[i]) == MIDI.NoteOnEvent
                    if typeof(Events[i-1]) == MIDI.PitchBendEvent
                        if Events[i-1].pitch == pitchBendDetector
                            append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note - 0.5)])
                        else
                            append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note)])
                        end
                    else
                        append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note)])
                    end
                    if noteIndex < length(notes)
                        noteIndex = noteIndex + 1
                    end
                end
            end
        end
    end
    
    if Avazname == "Homayoun" || Avazname == "Bayat e Esfahan" || Avazname == "Chahargah" || Avazname == "Segah"
        i = 1
        counter = 0
        for i in 1:length(Events)
            if typeof(Events[i]) == MIDI.PitchBendEvent
                counter = counter + 1
                if counter == 1
                    pitchBendDetector = Events[i].pitch
                end
                if counter == 2
                    pitchBendDetector2 = Events[i].pitch
                    break
                end
            end
        end
    
        result = []
        noteIndex = 1 
        while i < length(Events)
            if typeof(Events[i]) == MIDI.PitchBendEvent || typeof(Events[i]) == MIDI.NoteOnEvent
                if typeof(Events[i]) == MIDI.PitchBendEvent && Events[i].pitch == pitchBendDetector
                    i = i + 1
                    while i < length(Events)
                        if typeof(Events[i]) == MIDI.NoteOnEvent
                            append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note - 0.5)])
                            if noteIndex < length(notes)
                                noteIndex = noteIndex + 1
                            end
                            i = i + 1
                        else
                            i = i + 1
                        end
                        if typeof(Events[i]) == MIDI.PitchBendEvent && Events[i].pitch == pitchBendDetector2
                            i = i + 1
                            break
                        end
                    end
                elseif typeof(Events[i]) == MIDI.NoteOnEvent
                    append!(result, [Dict("Velocity"=> Int(notes[noteIndex].velocity),
                                        "Position"=> Int(notes[noteIndex].position),
                                        "Duration"=> Int(notes[noteIndex].duration),
                                        "Pitch"=> Events[i].note)])
                    if noteIndex < length(notes)
                        noteIndex = noteIndex + 1
                    end
                    i = i + 1
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
    end
    return result
end

function choose_the_track_and_return(path::String)
    Song = load(path)
    index = 0
    len = 0
    if length(Song.tracks) == 1
        return Song.tracks[1]
    else
        for i in range(1, length(Song.tracks))
            if length(Song.tracks[i].events) > len
                len = length(i)
                index = i
            end
        end
        return Song.tracks[index]
    end
end

function Load_Gushe_Notes(path::String,
                          GusheName::String,
                          Avazname::String,
                          DastgahName::String,
                          RadifName::String)
    TRACK = choose_the_track_and_return(path::String)
    Song = load(path)
    Gushe_Note_Attributes = Get_Modified_Iranian_Attributes(TRACK, Song.tpq, Avazname)
    Notes = Vector{IR_Note}(undef, length(Gushe_Note_Attributes))
    Counter = 1
    for i in range(1, length(Gushe_Note_Attributes))
        Notes[i] = IR_Note(NoteId(Counter, GusheName, Avazname, DastgahName, RadifName),
                IR_Pitch(Gushe_Note_Attributes[i]["Pitch"]),
                Gushe_Note_Attributes[i]["Velocity"],
                Charm.Midi.Time(Gushe_Note_Attributes[i]["Position"]),
                Charm.Midi.Duration(Gushe_Note_Attributes[i]["Duration"]))
        Counter = Counter + 1
    end
    return Notes
end

function IR_Load_Data(path)
    Data = JSON.parsefile(path)
    R = Data["Radifs"]
    D = R[1]["Dastgahs"]
    A = []
    for i in D
        append!(A, i["Avazes"])
    end
    G = []
    for i in A
        append!(G, [i["Gushes"]])
    end
    Gushes = [
        Vector{Gushe}(undef, length(G[1])),
        Vector{Gushe}(undef, length(G[2])),
        Vector{Gushe}(undef, length(G[3])),
        Vector{Gushe}(undef, length(G[4])),
        Vector{Gushe}(undef, length(G[5])),
        Vector{Gushe}(undef, length(G[6])),
        Vector{Gushe}(undef, length(G[7])),
        Vector{Gushe}(undef, length(G[8])),
        Vector{Gushe}(undef, length(G[9])),
        Vector{Gushe}(undef, length(G[10])),
        Vector{Gushe}(undef, length(G[11])),
        Vector{Gushe}(undef, length(G[12])),
        Vector{Gushe}(undef, length(G[13]))]
    for i in range(1, length(G))
        for j in range(1, length(G[i]))
            if i <= 6
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Shur", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Shur", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            elseif i == 7 || i == 8
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Homayoun", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Homayoun", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            elseif i == 9
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Mahur", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Mahur", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            elseif i == 10
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Segah", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Segah", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            elseif i == 11
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Chahargah", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Chahargah", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            elseif i == 12
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Rast Panjgah", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Rast Panjgah", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            else
                Gushes[i][j] = Gushe(GusheId(G[i][j]["Name"], A[i]["Name"], "Nava", "Mirza Abdollah"),
                        Load_Gushe_Notes(G[i][j]["Path"], G[i][j]["Name"], A[i]["Name"], "Nava", "Mirza Abdollah"),
                        G[i][j]["Alternative Note"],
                        G[i][j]["Temoin Note"],
                        G[i][j]["Arret Note"],
                        G[i][j]["Daramad"],
                        G[i][j]["Forud"],
                        G[i][j]["Modgardan"],
                        G[i][j]["Rhythmic"],
                        G[i][j]["Melodic"],
                        G[i][j]["Repeated in"],
                        G[i][j]["Sadeghi Importance"])
            end
        end
    end
    Avazes = Vector{Avaz}(undef, length(G))
    for i in range(1, length(G))
        if i <= 6
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Shur", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        elseif i == 7 || i == 8
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Homayoun", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        elseif i == 9
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Mahur", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        elseif i == 10
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Segah", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        elseif i == 11
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Chahargah", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        elseif i == 11
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Rast Panjgah", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        else
            Avazes[i] = Avaz(AvazId(A[i]["Name"], "Nava", "Mirza Abdollah"),
                Gushes[i],
                A[i]["Variable Note"],
                A[i]["Temoin Note"],
                A[i]["Arret Note"])
        end
    end
    Dastgahs = Vector{Dastgah}(undef, 7)
    Dastgahs[1] = Dastgah(DastgahId(D[1]["Name"], "Mirza Abdollah"),
        [Avazes[1], Avazes[2], Avazes[3], Avazes[4], Avazes[5], Avazes[6]],
        [Mojannab, Mojannab, Tanini, Tanini, Baghie, Tanini, Tanini,
        Mojannab, Mojannab, Tanini, Tanini, Baghie, Tanini, Tanini])
    Dastgahs[2] = Dastgah(DastgahId(D[2]["Name"], "Mirza Abdollah"),
        [Avazes[7], Avazes[8]],
        [Mojannab, Tanini_plus_Baghie, Baghie, Tanini, Baghie, Tanini, Tanini,
        Mojannab, Tanini_plus_Baghie, Baghie, Tanini, Baghie, Tanini, Tanini])
    Dastgahs[3] = Dastgah(DastgahId(D[3]["Name"], "Mirza Abdollah"),
        [Avazes[9]],
        [Tanini, Tanini, Baghie, Tanini, Tanini, Tanini, Baghie,
        Tanini, Tanini, Baghie, Tanini, Tanini, Tanini, Baghie])
    Dastgahs[4] = Dastgah(DastgahId(D[4]["Name"], "Mirza Abdollah"),
        [Avazes[10]],
        [Tanini, Mojannab, Mojannab, Tanini, Mojannab, Mojannab, Tanini,
        Tanini, Mojannab, Mojannab, Tanini, Mojannab, Mojannab, Tanini])
    Dastgahs[5] = Dastgah(DastgahId(D[5]["Name"], "Mirza Abdollah"),
        [Avazes[11]],
        [Mojannab, Tanini_plus_Baghie, Baghie, Tanini, Mojannab, Tanini_plus_Baghie, Baghie,
        Mojannab, Tanini_plus_Baghie, Baghie, Tanini, Mojannab, Tanini_plus_Baghie, Baghie])
    Dastgahs[6] = Dastgah(DastgahId(D[6]["Name"], "Mirza Abdollah"),
        [Avazes[12]],
        [Tanini, Tanini, Baghie, Tanini, Tanini, Baghie, Tanini,
        Tanini, Tanini, Baghie, Tanini, Tanini, Baghie, Tanini])
    Dastgahs[7] = Dastgah(DastgahId(D[7]["Name"], "Mirza Abdollah"),
        [Avazes[13]],
        [Mojannab, Mojannab, Tanini, Tanini, Baghie, Tanini, Tanini,
        Mojannab, Mojannab, Tanini, Tanini, Baghie, Tanini, Tanini])
    Radifs = [Radif(RadifId(R[1]["Name"]), Dastgahs)]
    return Radifs
end

# Change it to work for Hierarchy
function GetTheModgardans(Radif::Radif)
    ListOfModgardan = []
    for d in Radif.Dastgahs
        for a in d.Avazes
            for g in a.Gushes
                if length(g.Modgardan) > 0
                    M = [Modgardans(Radif.Id.RadifName, d.Id.DastgahName, a.Id.AvazName, g.Id.GusheName, g.Modgardan)]
                    append!(ListOfModgardan, M)
                end
            end
        end
    end
    return ListOfModgardan
end

function GetTheRepeated(Radif::Radif)
    ListOfRepeated = []
    for d in Radif.Dastgahs
        for a in d.Avazes
            for g in a.Gushes
                if length(g.Repeated_in) > 0
                    M = [Repeated(Radif.Id.RadifName, d.Id.DastgahName, a.Id.AvazName, g.Id.GusheName, g.Repeated_in)]
                    append!(ListOfRepeated, M)
                end
            end
        end
    end
    return ListOfRepeated
end

function GetTheMelodic(Radif::Radif)
    ListOfMelodic = []
    for d in Radif.Dastgahs
        for a in d.Avazes
            for g in a.Gushes
                if g.Melodic
                    M = [Melodic(Radif.Id.RadifName, d.Id.DastgahName, a.Id.AvazName, g.Id.GusheName)]
                    append!(ListOfMelodic, M)
                end
            end
        end
    end
    return ListOfMelodic
end

function GetTheRhythmic(Radif::Radif)
    ListOfRhythmic = []
    for d in Radif.Dastgahs
        for a in d.Avazes
            for g in a.Gushes
                if g.Rhythmic
                    M =[Rhythmic(Radif.Id.RadifName, d.Id.DastgahName, a.Id.AvazName, g.Id.GusheName)]
                    append!(ListOfRhythmic, M)
                end
            end
        end
    end
    return ListOfRhythmic
end

##########################################################################################
# Constituent Constructors

Chakra.pts(c::Radif) = [d.Id for d in c.Dastgahs]
Chakra.pts(c::Dastgah) = [a.Id for a in c.Avazes]
Chakra.pts(c::Avaz) = [g.Id for g in c.Gushes]
Chakra.pts(c::Gushe) = [n.Id for n in c.Notes]
Chakra.pts(c::IR_Note) = Chakra.none

function fndRadif(x::RadifId,h::IR_Hierarchy)
    for i in h.radifs
        if i.Id == x
            return i
        end
    end
    return Chakra.none
end

function fndDastgah(x::DastgahId,h::IR_Hierarchy)
    for i in h.radifs
        for j in i.Dastgahs
            if j.Id == x
                return j
            end
        end
    end
    return Chakra.none
end

function fndAvaz(x::AvazId,h::IR_Hierarchy)
    for i in h.radifs
        for j in i.Dastgahs
            for k in j.Avazes
                if k.Id == x
                    return k
                end
            end
        end
    end
    return Chakra.none
end

function fndGushe(x::GusheId,h::IR_Hierarchy)
    for i in h.radifs
        for j in i.Dastgahs
            for k in j.Avazes
                for t in k.Gushes
                    if t.Id == x
                        return t
                    end
                end
            end
        end
    end
    return Chakra.none
end

function fndNote(x::NoteId,h::IR_Hierarchy)
    for i in h.radifs
        for j in i.Dastgahs
            for k in j.Avazes
                for t in k.Gushes
                    for w in t.Notes
                        if w.Id == x
                            return w
                        end
                    end
                end
            end
        end
    end
    return Chakra.none
end

function IsItModgardan(x::Gushe)
    if length(x.Modgardan) == 0
        return false
    end
    return true
end

function VCheckGushe(x::Gushe)
    if x.Alternative_Note == 1000
        return false
    end
    return true
end
function TCheckGushe(x::Gushe)
    if x.Temoin_Note == 1000
        return false
    end
    return true
end
function ACheckGushe(x::Gushe)
    if x.Arret_Note == 1000
        return false
    end
    return true
end

function VCheckAvaz(x::Avaz)
    if x.Variable_Note == 1000
        return false
    end
    return true
end
function TCheckAvaz(x::Avaz)
    if x.Temoin_Note == 1000
        return false
    end
    return true
end
function ACheckAvaz(x::Avaz)
    if x.Arret_Note == []
        return false
    end
    return true
end


Chakra.fnd(x::RadifId,h::IR_Hierarchy) = fndRadif(x, h)
Chakra.fnd(x::DastgahId,h::IR_Hierarchy) = fndDastgah(x, h)
Chakra.fnd(x::AvazId,h::IR_Hierarchy) = fndAvaz(x, h)
Chakra.fnd(x::GusheId,h::IR_Hierarchy) = fndGushe(x, h)
Chakra.fnd(x::NoteId,h::IR_Hierarchy) = fndNote(x, h)

# Notes
Charm.getpitch(n::IR_Note)::IR_Pitch = n.pitch
Charm.getonset(n::IR_Note)::Charm.Midi.Time = n.position
Charm.getduration(n::IR_Note)::Charm.Midi.Duration = n.duration

# Gushes
getalternativenoteofgushe(g::Gushe)::Vector{Int} = g.Alternative_Note
gettemoinnoteofgushe(g::Gushe)::Int = g.Temoin_Note
getarretnoteofgushe(g::Gushe)::Int = g.Arret_Note
getmodgardan(g::Gushe)::Vector{String} = g.Modgardan
getrepeatedin(g::Gushe)::Vector{String} = g.Repeated_in
getsadeghiimportance(g::Gushe)::Int = g.Sadeghi_Importance

isitdaramad(g::Gushe)::Bool = g.Daramad
isitforud(g::Gushe)::Bool = g.Forud
isitmodgardan(g::Gushe)::Bool = IsItModgardan(g)
isitrhythmic(g::Gushe)::Bool = g.Rhythmic
isitmelodic(g::Gushe)::Bool = g.Melodic
doesithaalternativenoteofgushe(g::Gushe)::Bool = VCheckGushe(g)
doesithavetemoinnoteofgushe(g::Gushe)::Bool = TCheckGushe(g)
doesithavearretnoteofgushe(g::Gushe)::Bool = ACheckGushe(g)

# Avazes
getvariablenoteofavaz(a::Avaz)::Int = a.Variable_Note
gettemoinnoteofavaz(a::Avaz)::Int = a.Temoin_Note
getarretnoteofavaz(a::Avaz)::Int = a.Arret_Note

doesithavevariablenoteofavaz(a::Avaz)::Bool = VCheckAvaz(a)
doesithavetemoinnoteofavaz(a::Avaz)::Bool = TCheckAvaz(a)
doesithavearretnoteofavaz(a::Avaz)::Bool = ACheckAvaz(a)

# Dastgahs
getdastgahdomainintervals(d::Dastgah)::Vector{IR_Interval} = d.Dastgah_DomainـIntervals

Charm.getpitch(c::Chakra.Constituent) = Chakra.none
Charm.getonset(c::Chakra.Constituent) = Chakra.none
Charm.getduration(c::Chakra.Constituent) = Chakra.none

# Modgardans
function getavaz2avazModgardan(M)
    result = []
    for m in M
        for j in m.Modgardan_To
            append!(result, [[m.Avaz, j]])
        end
    end
    return unique(result)
end

# Events
Chakra.sequence(gushe::Gushe, h::IR_Hierarchy) = begin
    events = Vector{IR_Event}()
    Dastgah = fnd(DastgahId(gushe.Id.DastgahName, gushe.Id.RadifName), h)
    for n in gushe.Notes
        e = IR_Event(n.pitch, 
                     n.position,
                     n.duration, 
                     GusheName(gushe.Id.GusheName),
                     AvazName(gushe.Id.AvazName),
                     DastgahName(gushe.Id.DastgahName),
                     RadifName(gushe.Id.RadifName),
                     Dastgah.Dastgah_DomainـIntervals)
        push!(events,e)
    end
    return events
end

Chakra.sequence(avaz::Avaz, h::IR_Hierarchy) = begin
    list_event = Vector{Vector{IR_Event}}()
    for g in avaz.Gushes
        push!(list_event, Chakra.sequence(g, h))
    end
    return list_event
end

Chakra.sequence(dastgah::Dastgah, h::IR_Hierarchy) = begin
    list_event = Vector{IR_Seq}()
    for a in dastgah.Avazes
        for g in a.Gushes
            push!(list_event, Chakra.sequence(g, h))
        end
    end
    return list_event
end

Chakra.sequence(radif::Radif, h::IR_Hierarchy) = begin
    list_event = Vector{IR_Seq}()
    for d in radif.Dastgahs
        for a in d.Avazes
            for g in a.Gushes
                push!(list_event, Chakra.sequence(g, h))
            end
        end
    end
    return list_event
end

Chakra.sequence(h::IR_Hierarchy) = begin
    list_event = Vector{IR_Seq}()
    for r in h.radifs
        for d in r.Dastgahs
            for a in d.Avazes
                for g in a.Gushes
                    push!(list_event, Chakra.sequence(g, h))
                end
            end
        end
    end
    return list_event
end

##########################################################################################
# Viewpoints for Ir_Module
struct IR_Viewpoint{T} <: Chakra.Viewpoint{T}
    event_att::Symbol
    returntypes::Vector{Type}
    IR_Viewpoint(s, T) = new{T}(s, [T])
end

function (v::IR_Viewpoint{T})(s::IR_Seq)::Option{T} where T
    e = last(s)
    return Base.getproperty(e, v.event_att)
end

end
