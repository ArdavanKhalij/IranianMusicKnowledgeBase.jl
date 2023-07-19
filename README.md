# IranianMusicKnowledgeBase

 Install:
`pkg> add "https://github.com/ArdavanKhalij/IranianMusicKnowledgeBase.jl.git"`

## About the project

This package is a concrete implementation of [CHARM](https://github.com/nick-harley/Charm), and [CHAKRA](https://github.com/nick-harley/Chakra) for the Iranian traditional music.</br></br>
These systems are designed to deal with Western music, so the main challenge and work were adding the logic, new structures, and music theory of Iranian traditional music.</br></br>
An example of these extra components is Sori and Koron, which are a quarter of note and are essential and widespread in Iranian music. The other critical case that adds to the difficulties of representing Iranian music is Dastgah and Maqam. These are music structures with a specific combination of notes and structures similar to Western music’s mode. </br></br>
Other music representation challenges must be addressed before the statistical model is built. These new structures have been added to CHARM and CHAKRA.</br></br>

## JSON file

In Iranian music, some other attributes can affect the music radically, so in order to load the data, we need another approach that is different from Western music
because, in Western music, the only thing that is needed is the list of notes. So based on the challenge that has been described above, a JSON file has been made with
the same structure as the hierarchy that exists in Iranian music (Key, 2010; Khaleghi, 2002; Abdollah et al., 2018; Safvat et al., 2013; Abdollah and Talai, 2000) and the MirzaAbdollah Radif. </br></br>
Other Radifs Also will be added in the near future to the JSON file.</br></br>
It is important to mention that this JSON file designed based on the data in the Data directory and it will only work with those.</br></br>
Other than these attributes, a path also exists in each Gush´e. This field is the path to the Midi file with the notes. So all the attributes of Radifs, Dastgahs, Avazes, and Gush´es will be loaded from the JSON file implemented, and the notes will be received from the Midi files directly, based on the path mentioned.</br></br>

## Data

## How to use
