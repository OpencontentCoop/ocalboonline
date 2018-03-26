<?php /*

[General]
AllowedTypes[]=Query
AllowedTypes[]=MappaFamilyAudit
AllowedTypes[]=MappaFamilyInTrentino
AllowedTypes[]=MappaDistrettoFamiglia
AllowedTypes[]=MappaTnFam
AllowedTypes[]=MappaTnFamReverse

[Query]
Name=Lista automatica basata su query
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=query
CustomAttributeNames[]
CustomAttributeNames[query]=Query
CustomAttributeTypes[]
CustomAttributeTypes[query]=text
ViewList[]
ViewList[]=lista_num
ViewList[]=lista_accordion
ViewList[]=lista_box
ViewList[]=lista_carousel
ViewList[]=lista_carousel_wide
ViewList[]=lista_in_evidenza
ViewList[]=lista_in_evidenza_wide
ViewList[]=lista_masonry
ViewList[]=lista_banner
ViewName[]
ViewName[lista_num]=Carousel
ViewName[lista_accordion]=Accordion
ViewName[lista_box]=Elenco
ViewName[lista_carousel]=Slider
ViewName[lista_carousel_wide]=Slider wide
ViewName[lista_in_evidenza]=In evidenza
ViewName[lista_in_evidenza_wide]=In evidenza wide
ViewName[lista_masonry]=Masonry
ViewName[lista_banner]=Banner
ItemsPerRow[]
ItemsPerRow[lista_in_evidenza]=1
ItemsPerRow[lista_in_evidenza_wide]=1
ItemsPerRow[lista_carousel]=1
ItemsPerRow[lista_carousel_wide]=1

[MappaFamilyAudit]
Name=Mappa Family Audit
ManualAddingOfItems=disabled
CustomAttributes[]
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]

[MappaFamilyInTrentino]
Name=Mappa Family in Trentino
ManualAddingOfItems=disabled
CustomAttributes[]
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]

[MappaDistrettoFamiglia]
Name=Mappa Distretto Famiglia
ManualAddingOfItems=disabled
CustomAttributes[]
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]

[MappaTnFam]
Name=Mappa Trentino Famiglia (related object)
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=query
CustomAttributes[]=facets
CustomAttributes[]=attribute
CustomAttributeNames[]
CustomAttributeNames[query]=Query
CustomAttributeNames[facets]=Facets
CustomAttributeNames[attribute]=Indenficatore attributo relazione
CustomAttributeTypes[]
CustomAttributeTypes[query]=text
CustomAttributeTypes[facets]=text
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]

[MappaTnFamReverse]
Name=Mappa Trentino Famiglia (reverse related object)
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=query
CustomAttributes[]=facets
CustomAttributes[]=class
CustomAttributes[]=attribute
CustomAttributeNames[]
CustomAttributeNames[query]=Query
CustomAttributeNames[facets]=Facets
CustomAttributeNames[class]=Classe in relazione inversa
CustomAttributeNames[attribute]=Indenficatore attributo classe in relazione inversa
CustomAttributeTypes[]
CustomAttributeTypes[query]=text
CustomAttributeTypes[facets]=text
ViewList[]
ViewList[]=default
ViewName[]
ViewName[default]=Default
ItemsPerRow[]
