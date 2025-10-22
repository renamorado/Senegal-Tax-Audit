
*Clean information about vérificateurs
ds verificateur* 
foreach v in `r(varlist)' {
	
	replace `v' = ustrupper( ustrregexra( ustrnormalize(`v', "nfd" ) , "\p{Mark}", "" ) )	

}



foreach x in "" 0 1 2 3 4 5 6 7 8 {

	cap noisily replace verificateur`x' = trim(verificateur`x')
	cap noisily replace verificateur`x' = upper(verificateur`x')
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "-", "", .)
	cap noisily replace verificateur`x' = ustrupper( ustrregexra( ustrnormalize(verificateur`x', "nfd" ) , "\p{Mark}", "" ) )	
	cap noisily replace verificateur`x' = subinstr(verificateur`x', ".", "", .)	
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "  ", " ", .)	
	cap noisily replace verificateur`x' = trim(verificateur`x')
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "ABDOU ", "ABDOUL ", .) 
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "HADJI ", "HADJ ", .) 
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "SSS ", "SS ", .) 
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "DIOME ", "DIOM", .) 
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "MAMMADOU ", "MAMADOU", .) 
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "DIAWARA ", "DIAVARA", .) 

	cap noisily replace verificateur`x' = "YAYA HANE" if strpos(verificateur`x', "YAYA") > 0 & strpos(verificateur`x', "HAN") > 0 
	cap noisily replace verificateur`x' = "RENE AUGUSTIN DIOH" if strpos(verificateur`x', "RENE") > 0 & strpos(verificateur`x', "DIO") > 0 
	cap noisily replace verificateur`x' = "ALHOUSSEYNOU KELLY" if strpos(verificateur`x', "ALHOUSS") > 0 & strpos(verificateur`x', "KELLY") > 0 
	cap noisily replace verificateur`x' = "ALIOUNE BADARA SANE" if strpos(verificateur`x', "ALIOU") > 0 & strpos(verificateur`x', "SANE")  > 0 
	cap noisily replace verificateur`x' = "ALLE MADIAO KHOR DIOP" if strpos(verificateur`x', "ALLE M") > 0 & strpos(verificateur`x', "DIOP") > 0 
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if strpos(verificateur`x', "BAYE") > 0 & strpos(verificateur`x', "SAMB") > 0 
	cap noisily replace verificateur`x' = "CHEIKH IBRAHIMA DIENG" if strpos(verificateur`x', "CHEIKH I") > 0 & strpos(verificateur`x', "DIENG") > 0 
	cap noisily replace verificateur`x' = "EL ASSANE CISSE MBAYE" if strpos(verificateur`x', "EL ASSANE C") > 0 & strpos(verificateur`x', "MBAYE") > 0 
	cap noisily replace verificateur`x' = "IBRAHIMA S B NDIAYE" if strpos(verificateur`x', "IBRAHIMA") > 0 & strpos(verificateur`x', "SB") & strpos(verificateur`x', "NDIAYE") > 0 
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if strpos(verificateur`x', "ISMAILA") > 0 & strpos(verificateur`x', "DIEME") > 0 
	cap noisily replace verificateur`x' = "MAIMOUNA FATOU FAYE" if strpos(verificateur`x', "M FATOU") > 0 & strpos(verificateur`x', "FAYE") > 0 
	cap noisily replace verificateur`x' = "MAIMOUNA FATOU FAYE" if strpos(verificateur`x', "MAIMOUNA FATOU") > 0 & strpos(verificateur`x', "FAYE") > 0 
	cap noisily replace verificateur`x' = "MAMADOU LAMINE NDIAYE" if strpos(verificateur`x', "MAMADOU L") > 0 & strpos(verificateur`x', "NDIAYE") > 0 
	cap noisily replace verificateur`x' = "MAME MASSARA NDIOR NDOUR" if strpos(verificateur`x', "MAME MASSARA N") > 0 
	cap noisily replace verificateur`x' = "MARIAMA SIRA SOW" if strpos(verificateur`x', "MARIAMA S SOW") > 0 
	cap noisily replace verificateur`x' = "MARIAMA SIRA SOW" if strpos(verificateur`x', "MARIAMA SOW") > 0 
	cap noisily replace verificateur`x' = "MOUR GUEYE SAMB" if strpos(verificateur`x', "MOUR G") > 0 & strpos(verificateur`x', "SAM") > 0 
	cap noisily replace verificateur`x' = "NDEYE MAREME G CISSE" if strpos(verificateur`x', "NDEYE MAREME") > 0 & strpos(verificateur`x', "CISSE") > 0 
	cap noisily replace verificateur`x' = "NDEYE NANGHO DIOUM" if strpos(verificateur`x', "NDEYE N") > 0 & strpos(verificateur`x', "DIO") > 0 
	cap noisily replace verificateur`x' = "NDEYE SOKHNA DIA" if strpos(verificateur`x', "NDEYE S") > 0 & strpos(verificateur`x', "DIA") > 0 
	cap noisily replace verificateur`x' = "OUMAR BELLA COLY" if strpos(verificateur`x', "OUMAR BELLE COLY") > 0 
	cap noisily replace verificateur`x' = "PAPA MACODOU DIOUF" if strpos(verificateur`x', "PAPA MACOUDOU DIOUF") > 0 
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if strpos(verificateur`x', "SERIGNE MB KA") > 0 
	cap noisily replace verificateur`x' = "MAMADOU MOUTAROU DIALLO" if strpos(verificateur`x', "MAMADOU M DIALLO") > 0 
	cap noisily replace verificateur`x' = "MAME MASSARA NDIOR NDOUR" if strpos(verificateur`x', "MAME MASSAR NDIOR NDOUR") > 0 
	cap noisily replace verificateur`x' = "SERIGNE SALIOU SEYE" if strpos(verificateur`x', "SERIGNE S SEYE") > 0 


	cap noisily replace verificateur`x' = "ABDOU KARIM CAMARA" if verificateur`x' == "ABDOU K. CAMARA"
	cap noisily replace verificateur`x' = "ABDOU SAMB" if verificateur`x' == "ABDOU  SAMB"
	cap noisily replace verificateur`x' = "YAYA HANE" if verificateur`x' == "YAYA HANNE"
	cap noisily replace verificateur`x' = "ALAIN F. FAYE" if verificateur`x' == "ALAIN F.FAYE"
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if verificateur`x' == "ALAIN FRANçOIS FAYE"
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if verificateur`x' == "SERIGNE MB KA"
	cap noisily replace verificateur`x' = "PAPA MACOUDOU DIOUF" if verificateur`x' == "PAPA MACODOU DIOUF"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA P. B. DIEME"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA P.B DIEME"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA PAPE BEN DIéMé"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA N. NDOUR"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA NDIOR"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA NDIOR NDOUR"
	cap noisily replace verificateur`x' = "PAUL DIBOCOR NDOUR" if verificateur`x' == "PAUL D. NDOUR"
	cap noisily replace verificateur`x' = "OUMAR DIACK" if verificateur`x' == "OUMAR DIACK PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x' = "NDEYE N DIOUM" if verificateur`x' == "NDEYE N. DIOUM"
	cap noisily replace verificateur`x' = "NDEYE N DIOUM" if verificateur`x' == "NDEYE NANGHO DIOUM"
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if verificateur`x' == "PAPA MAHEHADOUNE"
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if verificateur`x' == "ALAIN F. FAYE"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLé MADIAO KHOR DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE MADIAO KHOR DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE MADIAO K. DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE M.K. DIOP"
	cap noisily replace verificateur`x' = "MACOUMBA NIANG" if verificateur`x' == "MACOUMBA NINAG"
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if verificateur`x' == "BAYE S. SAMB"
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if verificateur`x' == "BAYE S SAMB"
	cap noisily replace verificateur`x' = "ALHOUSSEYNI KELLY" if verificateur`x' == "ALHOUSSEYNOU KELLY"
	cap noisily replace verificateur`x' = "MAMADOU MOUTAROU DIALLO" if verificateur`x' == "MAMADOU M. DIALLO"
	cap noisily replace verificateur`x' = "PAPE MALICK DIALLO" if verificateur`x' == "PAPE M. DIALLO"
	cap noisily replace verificateur`x' = "OUMAR DIACK" if verificateur`x' == "OMAR DIACK"
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if strpos(verificateur`x', "PAPE MAHEMADOUNE FALL") >0 
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if verificateur`x' == "PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x' = "MOUHAMADOU SECK" if verificateur`x' == "MOUHAMADOU A. SECK"
	cap noisily replace verificateur`x' = "PAPA MALICK DIALLO" if verificateur`x' == "PAPE MALICK DIALLO"
	cap noisily replace verificateur`x' = "PAPA MALICK DIALLO" if verificateur`x' == "PAPA M. DIALLO"
	cap noisily replace verificateur`x' = "GORGUI CISSE" if verificateur`x' == "GORGUI CISSSE"
	cap noisily replace verificateur`x' = "ABDOUL AZIZ GUEYE" if verificateur`x' == "ABDOUL A. GUEYE"
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if verificateur`x' == "SERIGNE MBACKé KA"
	cap noisily replace verificateur`x' = "SERIGNE SALIOU SEYE" if verificateur`x' == "SERIGNE S. SEYE"
	cap noisily replace verificateur`x' = "ABDOUL AZIZ DIAGNE" if verificateur`x' == "ABDOUL A.DIAGNE"
	cap noisily replace verificateur`x' = "ABDOUL AZIZ DIAGNE" if verificateur`x' == "ABDOUL A. DIAGNE"
	cap noisily replace verificateur`x' = "AL HOUSSEYNI KELLY" if verificateur`x' == "AL OUSSEYNI KELLY"
	cap noisily replace verificateur`x' = "SOULEYMANE SENE" if strpos(verificateur`x', "SOULEYMANE SENE") > 0
	cap noisily replace verificateur`x' = "RAMATA SOW" if strpos(verificateur`x', "RAMATA SOW") > 0
	cap noisily replace verificateur`x' = "FATOU NIANG" if strpos(verificateur`x', "FATOU NIANG") > 0
	cap noisily replace verificateur`x' = "AMETH DIEYE" if strpos(verificateur`x', "AMETH DIEYE") > 0
	cap noisily replace verificateur`x' = "MAIMOUNA FATOU FAYE" if strpos(verificateur`x', "MAIMOUNA F,FAYE") > 0
	
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "ABDOU ", "ABDOUL ", .)
	cap noisily replace verificateur`x'= "ABDOU KARIM CAMARA" if verificateur`x'== "ABDOU K. CAMARA"
	cap noisily replace verificateur`x'= "ABDOU SAMB" if verificateur`x'== "ABDOU  SAMB"
	cap noisily replace verificateur`x'= "YAYA HANE" if verificateur`x'== "YAYA HANNE"
	cap noisily replace verificateur`x'= "ALAIN F. FAYE" if verificateur`x'== "ALAIN F.FAYE"
	cap noisily replace verificateur`x'= "SERIGNE MBACKE KA" if verificateur`x'== "SERIGNE MB KA"
	cap noisily replace verificateur`x'= "PAPA MACOUDOU DIOUF" if verificateur`x'== "PAPA MACODOU DIOUF"
	cap noisily replace verificateur`x'= "ISMAILA PAPE BEN DIEME" if verificateur`x'== "ISMAILA P. B. DIEME"
	cap noisily replace verificateur`x'= "ISMAILA PAPE BEN DIEME" if verificateur`x'== "ISMAILA P.B DIEME"
	cap noisily replace verificateur`x'= "ISMAILA PAPE BEN DIEME" if strpos(verificateur`x', "PAPA I") > 0 & strpos(verificateur`x', "DIEME") > 0 
	cap noisily replace verificateur`x'= "ISMAILA PAPE BEN DIEME" if verificateur`x'== "ISMAILA PAPE BEN DIéMé"
	cap noisily replace verificateur`x'= "MAME MASSAR NDIOR NDOUR" if verificateur`x'== "MAME MASSARA N. NDOUR"
	cap noisily replace verificateur`x'= "MAME MASSAR NDIOR NDOUR" if verificateur`x'== "MAME MASSARA NDIOR"
	cap noisily replace verificateur`x'= "MAME MASSAR NDIOR NDOUR" if verificateur`x'== "MAME MASSARA NDIOR NDOUR"
	cap noisily replace verificateur`x'= "PAUL DIBOCOR NDOUR" if verificateur`x'== "PAUL D. NDOUR"
	cap noisily replace verificateur`x'= "OUMAR DIACK" if verificateur`x'== "OUMAR DIACK PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x'= "NDEYE N DIOUM" if verificateur`x'== "NDEYE N. DIOUM"
	cap noisily replace verificateur`x'= "NDEYE N DIOUM" if verificateur`x'== "NDEYE NANGHO DIOUM"
	cap noisily replace verificateur`x'= "PAPA MAHEMADOUNE FALL" if verificateur`x'== "PAPA MAHEHADOUNE"
	cap noisily replace verificateur`x'= "ALAIN FRANCOIS FAYE" if verificateur`x'== "ALAIN F. FAYE"
	cap noisily replace verificateur`x'= "ALLE M. K. DIOP" if verificateur`x'== "ALLé MADIAO KHOR DIOP"
	cap noisily replace verificateur`x'= "ALLE M. K. DIOP" if verificateur`x'== "ALLE MADIAO KHOR DIOP"
	cap noisily replace verificateur`x'= "ALLE M. K. DIOP" if verificateur`x'== "ALLE MADIAO K. DIOP"
	cap noisily replace verificateur`x'= "ALLE M. K. DIOP" if verificateur`x'== "ALLE M.K. DIOP"
	cap noisily replace verificateur`x'= "MACOUMBA NIANG" if verificateur`x'== "MACOUMBA NINAG"
	cap noisily replace verificateur`x'= "BAYE SOULEYMANE SAMB" if verificateur`x'== "BAYE S. SAMB"
	cap noisily replace verificateur`x'= "BAYE SOULEYMANE SAMB" if verificateur`x'== "BAYE S SAMB"
	cap noisily replace verificateur`x'= "ALHOUSSEYNI KELLY" if verificateur`x'== "ALHOUSSEYNOU KELLY"
	cap noisily replace verificateur`x'= "MAMADOU MOUTAROU DIALLO" if verificateur`x'== "MAMADOU M. DIALLO"
	cap noisily replace verificateur`x'= "PAPE MALICK DIALLO" if verificateur`x'== "PAPE M. DIALLO"
	cap noisily replace verificateur`x'= "OUMAR DIACK" if verificateur`x'== "OMAR DIACK"
	cap noisily replace verificateur`x'= "PAPA MAHEMADOUNE FALL" if verificateur`x'== "PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x'= "MOUHAMADOU SECK" if verificateur`x'== "MOUHAMADOU A. SECK"
	cap noisily replace verificateur`x'= "PAPA MALICK DIALLO" if verificateur`x'== "PAPE MALICK DIALLO"
	cap noisily replace verificateur`x'= "PAPA MALICK DIALLO" if verificateur`x'== "PAPA M. DIALLO"
	cap noisily replace verificateur`x'= "GORGUI CISSE" if verificateur`x'== "GORGUI CISSSE"
	cap noisily replace verificateur`x'= "ABDOUL AZIZ GUEYE" if verificateur`x'== "ABDOUL A. GUEYE"
	cap noisily replace verificateur`x'= "SERIGNE MBACKE KA" if verificateur`x'== "SERIGNE MBACKé KA"
	cap noisily replace verificateur`x'= "SERIGNE SALIOU SEYE" if verificateur`x'== "SERIGNE S. SEYE"
	cap noisily replace verificateur`x'= "ABDOUL AZIZ DIAGNE" if verificateur`x'== "ABDOUL A.DIAGNE"
	cap noisily replace verificateur`x'= "ABDOUL AZIZ DIAGNE" if verificateur`x'== "ABDOUL A. DIAGNE"
	cap noisily replace verificateur`x'= "AL HOUSSEYNI KELLY" if verificateur`x'== "AL OUSSEYNI KELLY"
	cap noisily replace verificateur`x'= "YOUSSOUF DIONE" if verificateur`x'== "YOUSSOUF DIONNE"
	cap noisily replace verificateur`x'= "TALLA NIANG" if verificateur`x'== "TAALA NIANG"
	cap noisily replace verificateur`x'= "SOULEYMANE SENE" if strpos(verificateur`x', "SOULEYM") > 0 &  strpos(verificateur`x', "SENE") > 0 
	cap noisily replace verificateur`x'= "SOUHAIBOU DIAGNE" if strpos(verificateur`x', "SOUH") > 0 &  strpos(verificateur`x', "DIAGNE") > 0 
	cap noisily replace verificateur`x'= "YATTA DIOP" if strpos(verificateur`x', "YATTA") > 0 &  strpos(verificateur`x', "DIOP") > 0 
	cap noisily replace verificateur`x'= "RENE AUGUSTIN DIOKH" if strpos(verificateur`x', "RENE") > 0 &  strpos(verificateur`x' ,"DIO") > 0 
	cap noisily replace verificateur`x'= "RAMATA SOW" if strpos(verificateur`x', "RAMATA") > 0 &  strpos(verificateur`x' ,"SOW") > 0 
	cap noisily replace verificateur`x'= "PAPE MAMADOU NDIAYE" if strpos(verificateur`x', "PAPA") > 0 &  strpos(verificateur`x', "MAMADOU") > 0  &  strpos(verificateur`x', "NDIAYE") > 0
	cap noisily replace verificateur`x'= "ABDEL KADER SOW" if strpos(verificateur`x', "AB") > 0 &  strpos(verificateur`x' ,"K") > 0  &  strpos(verificateur`x', "SOW") > 0
	cap noisily replace verificateur`x'= "ABDOU SAMBE" if strpos(verificateur`x', "ABDOU SAMB") > 0 
	cap noisily replace verificateur`x'= "ABDOU SY" if strpos(verificateur`x', "ABDOUL SY") > 0 
	cap noisily replace verificateur`x'= "ALIOUNE BADARA SANE" if strpos(verificateur`x', "ALIOUNE BADARA SANE") > 0 
	cap noisily replace verificateur`x'= "AMADOU LY" if strpos(verificateur`x', "AMADOU") > 0  & strpos(verificateur`x', "LY") > 0 
	cap noisily replace verificateur`x'= "ALLE M. K. DIOP" if strpos(verificateur`x', "ALLE M K DIOP") > 0  
	cap noisily replace verificateur`x'= "BANTA MAGASSOUBA" if strpos(verificateur`x', "BANTA MANGASSOUBA") > 0  
	cap noisily replace verificateur`x'= "SERIGNE MBACKE KA" if strpos(verificateur`x', "SERIGNE M KA") > 0  
	cap noisily replace verificateur`x'= "MAMADOU LAMINE NDIAYE" if strpos(verificateur`x', "MAMADOU L. NDIAYE") > 0  
	cap noisily replace verificateur`x'= "FATOU NIANG" if strpos(verificateur`x', "FATOU NIANG") > 0  
	cap noisily replace verificateur`x'= "EL ASSANE CISSE MBAYE" if strpos(verificateur`x', "EL ASSANCE CISSE MBAYE") > 0  
	cap noisily replace verificateur`x'= "CHEIKHNA IBRAHIMA SECK" if strpos(verificateur`x', "CHEIKHNA I SECK") > 0  
	cap noisily replace verificateur`x'= "BIRANE DIOP" if strpos(verificateur`x', "BIRAME DIOP") > 0  
	cap noisily replace verificateur`x'= "AL HOUSSEYNI KELLY" if strpos(verificateur`x', "ALHOUSSEYNI KELLY") > 0  
	cap noisily replace verificateur`x' = "EL HADJ ALPHOUSSEYNI BODIAN" if strpos(verificateur`x', "ALPHOUSSEYNI BODIAN") > 0  	
	
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if strpos(verificateur`x', "ALAIN F") > 0 & strpos(verificateur`x', "FAYE") > 0
	cap noisily replace verificateur`x' = "YAYA HANE" if strpos(verificateur`x', "YAYA") > 0 & strpos(verificateur`x', "HAN") > 0
	cap noisily replace verificateur`x' = "RENE AUGUSTIN DIOH" if strpos(verificateur`x', "RENE") > 0 & strpos(verificateur`x', "DIO") > 0
	cap noisily replace verificateur`x' = "ALHOUSSEYNOU KELLY" if strpos(verificateur`x', "ALHOUSS") > 0 & strpos(verificateur`x', "KELLY") > 0
	cap noisily replace verificateur`x' = "ALLE MADIAO KHOR DIOP" if strpos(verificateur`x', "ALLE M") > 0 & strpos(verificateur`x', "DIOP") > 0
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if strpos(verificateur`x', "BAYE") > 0 & strpos(verificateur`x', "SAMB") > 0
	cap noisily replace verificateur`x' = "CHEIKH IBRAHIMA DIENG" if strpos(verificateur`x', "CHEIKH I") > 0 & strpos(verificateur`x', "DIENG") > 0 
	cap noisily replace verificateur`x' = "EL ASSANE CISSE MBAYE" if strpos(verificateur`x', "EL ASSANE C") > 0 & strpos(verificateur`x', "MBAYE") > 0 
	cap noisily replace verificateur`x' = "IBRAHIMA S B NDIAYE" if strpos(verificateur`x', "IBRAHIMA") > 0 & strpos(verificateur`x', "SB") & strpos(verificateur`x', "NDIAYE") > 0
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if strpos(verificateur`x', "ISMAILA") > 0 & strpos(verificateur`x', "DIEME") > 0
	cap noisily replace verificateur`x' = "MAIMOUNA FATOU FAYE" if strpos(verificateur`x', "M FATOU") > 0 & strpos(verificateur`x', "FAYE") > 0
	cap noisily replace verificateur`x' = "MAIMOUNA FATOU FAYE" if strpos(verificateur`x', "MAIMOUNA FATOU") > 0 & strpos(verificateur`x', "FAYE") > 0 
	cap noisily replace verificateur`x' = "MAMADOU LAMINE NDIAYE" if strpos(verificateur`x', "MAMADOU L") > 0 & strpos(verificateur`x', "NDIAYE") > 0
	cap noisily replace verificateur`x' = "MAMADOU NDIAYE DIOME" if strpos(verificateur`x', "MAMADOU NDIAYE") > 0 
	cap noisily replace verificateur`x' = "MAME MASSARA NDIOR NDOUR" if strpos(verificateur`x', "MAME MASSARA N") > 0 
	cap noisily replace verificateur`x' = "MARIAMA SIRA SOW" if strpos(verificateur`x', "MARIAMA S SOW") > 0 
	cap noisily replace verificateur`x' = "MARIAMA SIRA SOW" if strpos(verificateur`x', "MARIAMA SOW") > 0 
	cap noisily replace verificateur`x' = "MOUR GUEYE SAMB" if strpos(verificateur`x', "MOUR G") > 0 & strpos(verificateur`x', "SAM") > 0
	cap noisily replace verificateur`x' = "NDEYE MAREME G CISSE" if strpos(verificateur`x', "NDEYE MAREME") > 0 & strpos(verificateur`x', "CISSE") > 0 
	cap noisily replace verificateur`x' = "NDEYE NANGHO DIOUM" if strpos(verificateur`x', "NDEYE N") > 0 & strpos(verificateur`x', "DIO") > 0
	cap noisily replace verificateur`x' = "NDEYE SOKHNA DIA" if strpos(verificateur`x', "NDEYE S") > 0 & strpos(verificateur`x', "DIA") > 0
	cap noisily replace verificateur`x' = "OUMAR BELLA COLY" if strpos(verificateur`x', "OUMAR BELLE COLY") > 0 
	cap noisily replace verificateur`x' = "PAPA MACODOU DIOUF" if strpos(verificateur`x', "PAPA MACOUDOU DIOUF") > 0 
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if strpos(verificateur`x', "SERIGNE MB KA") > 0 
	cap noisily replace verificateur`x' = "MAMADOU MOUTAROU DIALLO" if strpos(verificateur`x', "MAMADOU M DIALLO") > 0 
	cap noisily replace verificateur`x' = "MAME MASSARA NDIOR NDOUR" if strpos(verificateur`x', "MAME MASSAR NDIOR NDOUR") > 0 

	cap noisily replace verificateur`x' = "ABDOU KARIM CAMARA" if verificateur`x' == "ABDOU K. CAMARA"
	cap noisily replace verificateur`x' = "ABDOU SAMB" if verificateur`x' == "ABDOU  SAMB"
	cap noisily replace verificateur`x' = "YAYA HANE" if verificateur`x' == "YAYA HANNE"
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if verificateur`x' == "ALAIN F.FAYE"
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if verificateur`x' == "ALAIN FRANçOIS FAYE"
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if verificateur`x' == "SERIGNE MB KA"
	cap noisily replace verificateur`x' = "PAPA MACOUDOU DIOUF" if verificateur`x' == "PAPA MACODOU DIOUF"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA P. B. DIEME"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA P.B DIEME"
	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if verificateur`x' == "ISMAILA PAPE BEN DIéMé"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA N. NDOUR"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA NDIOR"
	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if verificateur`x' == "MAME MASSARA NDIOR NDOUR"
	cap noisily replace verificateur`x' = "PAUL DIBOCOR NDOUR" if verificateur`x' == "PAUL D. NDOUR"
	cap noisily replace verificateur`x' = "OUMAR DIACK" if verificateur`x' == "OUMAR DIACK PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x' = "NDEYE N DIOUM" if verificateur`x' == "NDEYE N. DIOUM"
	cap noisily replace verificateur`x' = "NDEYE N DIOUM" if verificateur`x' == "NDEYE NANGHO DIOUM"
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if verificateur`x' == "PAPA MAHEHADOUNE"
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if verificateur`x' == "ALAIN F. FAYE"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLé MADIAO KHOR DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE MADIAO KHOR DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE MADIAO K. DIOP"
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if verificateur`x' == "ALLE M.K. DIOP"
	cap noisily replace verificateur`x' = "MACOUMBA NIANG" if verificateur`x' == "MACOUMBA NINAG"
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if verificateur`x' == "BAYE S. SAMB"
	cap noisily replace verificateur`x' = "BAYE SOULEYMANE SAMB" if verificateur`x' == "BAYE S SAMB"
	cap noisily replace verificateur`x' = "ALHOUSSEYNI KELLY" if verificateur`x' == "ALHOUSSEYNOU KELLY"
	cap noisily replace verificateur`x' = "MAMADOU MOUTAROU DIALLO" if verificateur`x' == "MAMADOU M. DIALLO"
	cap noisily replace verificateur`x' = "PAPE MALICK DIALLO" if verificateur`x' == "PAPE M. DIALLO"
	cap noisily replace verificateur`x' = "OUMAR DIACK" if verificateur`x' == "OMAR DIACK"
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if strpos(verificateur`x', "PAPE MAHEMADOUNE FALL") >0 
	cap noisily replace verificateur`x' = "PAPA MAHEMADOUNE FALL" if verificateur`x' == "PAPA MOUHAMEDINE FALL"
	cap noisily replace verificateur`x' = "MOUHAMADOU SECK" if verificateur`x' == "MOUHAMADOU A. SECK"
	cap noisily replace verificateur`x' = "PAPA MALICK DIALLO" if verificateur`x' == "PAPE MALICK DIALLO"
	cap noisily replace verificateur`x' = "PAPA MALICK DIALLO" if verificateur`x' == "PAPA M. DIALLO"
	cap noisily replace verificateur`x' = "GORGUI CISSE" if verificateur`x' == "GORGUI CISSSE"
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if verificateur`x' == "SERIGNE MBACKé KA"
	cap noisily replace verificateur`x' = "SERIGNE SALIOU SEYE" if verificateur`x' == "SERIGNE S. SEYE"
	cap noisily replace verificateur`x' = "ABDOUL AZIZ DIAGNE" if verificateur`x' == "ABDOUL A.DIAGNE"
	cap noisily replace verificateur`x' = "ABDOUL AZIZ DIAGNE" if verificateur`x' == "ABDOUL A. DIAGNE"
	cap noisily replace verificateur`x' = "AL HOUSSEYNI KELLY" if verificateur`x' == "AL OUSSEYNI KELLY"
	cap noisily replace verificateur`x' = "YOUSSOUF DIONE" if verificateur`x' == "YOUSSOUF DIONNE"
	cap noisily replace verificateur`x' = "TALLA NIANG" if verificateur`x' == "TAALA NIANG"

	cap noisily replace verificateur`x' = "SOULEYMANE SENE" if strpos(verificateur`x', "SOULEYM") > 0 &  strpos(verificateur`x', "SENE") > 0 
	cap noisily replace verificateur`x' = "SOUHAIBOU DIAGNE" if strpos(verificateur`x', "SOUH") > 0 &  strpos(verificateur`x', "DIAGNE") > 0 
	cap noisily replace verificateur`x' = "YATTA DIOP" if strpos(verificateur`x', "YATTA") > 0 &  strpos(verificateur`x', "DIOP") > 0 
	cap noisily replace verificateur`x' = "RENE AUGUSTIN DIOKH" if strpos(verificateur`x', "RENE") > 0 &  strpos(verificateur`x', "DIO") > 0 
	cap noisily replace verificateur`x' = "RAMATA SOW" if strpos(verificateur`x', "RAMATA") > 0 &  strpos(verificateur`x', "SOW") > 0 
	cap noisily replace verificateur`x' = "PAPE MAMADOU NDIAYE" if strpos(verificateur`x', "PAPA") > 0 &  strpos(verificateur`x', "MAMADOU") > 0  &  strpos(verificateur`x', "NDIAYE") > 0
	cap noisily replace verificateur`x' = "ABDEL KADER SOW" if strpos(verificateur`x', "AB") > 0 &  strpos(verificateur`x', "K") > 0  &  strpos(verificateur`x', "SOW") > 0
	cap noisily replace verificateur`x' = "ABDOU SAMBE" if strpos(verificateur`x', "ABDOU SAMB") > 0 
	cap noisily replace verificateur`x' = "ABDOU SY" if strpos(verificateur`x', "ABDOUL SY") > 0 
	cap noisily replace verificateur`x' = "ALAIN FRANCOIS FAYE" if strpos(verificateur`x', "ALAIN FR") > 0 
	cap noisily replace verificateur`x' = "ALIOUNE BADARA SANE" if strpos(verificateur`x', "ALIOUNE BADARA SANE") > 0 
	cap noisily replace verificateur`x' = "AMADOU LY" if strpos(verificateur`x', "AMADOU") > 0  & strpos(verificateur`x', "LY") > 0 
	cap noisily replace verificateur`x' = "ALLE M. K. DIOP" if strpos(verificateur`x', "ALLE M K DIOP") > 0  
	cap noisily replace verificateur`x' = "BANTA MAGASSOUBA" if strpos(verificateur`x', "BANTA MANGASSOUBA") > 0  
	cap noisily replace verificateur`x' = "SERIGNE MBACKE KA" if strpos(verificateur`x', "SERIGNE M KA") > 0  
	cap noisily replace verificateur`x' = "MAMADOU LAMINE NDIAYE" if strpos(verificateur`x', "MAMADOU L. NDIAYE") > 0  
	cap noisily replace verificateur`x' = "FATOU NIANG" if strpos(verificateur`x', "FATOU NIANG") > 0  
	cap noisily replace verificateur`x' = "CHEIKHNA IBRAHIMA SECK" if strpos(verificateur`x', "CHEIKHNA I SECK") > 0  
	cap noisily replace verificateur`x' = "BIRANE DIOP" if strpos(verificateur`x', "BIRAME DIOP") > 0  
	cap noisily replace verificateur`x' = subinstr(verificateur`x', "ABDOU ", "ABDOUL ", .)
	cap noisily replace verificateur`x' = "AL HOUSSEYNI KELLY" if strpos(verificateur`x', "ALHOUSSEYNI KELLY") > 0  
	cap noisily replace verificateur`x' = "EL HADJ ALPHOUSSEYNI BODIAN" if strpos(verificateur`x', "ALPHOUSSEYNI BODIAN") > 0  
	cap noisily replace verificateur`x' = "ABDEL KADER WADE" if strpos(verificateur`x' , "ABDEL K WADE") > 0  

	cap noisily replace verificateur`x' = "AMINATA SECK" if strpos(verificateur`x' , "AMINATA SECK") > 0  
	cap noisily replace verificateur`x' = "CHEIKH SADIBOU SY" if strpos(verificateur`x' , "CHEIKH SAADBOU SY") > 0  
	cap noisily replace verificateur`x' = "COURA SIMAL" if strpos(verificateur`x' , "COURA SIMAL") > 0  
	cap noisily replace verificateur`x' = "ISMAILA BEN PAPA DIEME" if strpos(verificateur`x' , "ISMAILA BEN PAPE DIEME") > 0  
	cap noisily replace verificateur`x' = "MADA SARR" if strpos(verificateur`x' , "MADA SARR") > 0  
	cap noisily replace verificateur`x' = "MOUR GUEYE SAMBE" if strpos(verificateur`x' , "MOUR GUEYE SAMB") > 0  
	cap noisily replace verificateur`x' = "PAPE SAMBA COULIBALY" if strpos(verificateur`x' , "PAPA SAMBA COULIBALY") > 0 
	cap noisily replace verificateur`x' = "TALLA NIANG" if verificateur`x' ==  "TALLA"
	cap noisily replace verificateur`x' = "ALIOU SY" if verificateur`x' ==  "ALIOU"
	cap noisily replace verificateur`x' = "ASSANE DIALLO" if verificateur`x' ==  "ASSANE"
	cap noisily replace verificateur`x' = "IBRAHIMA DIOME" if verificateur`x' ==  "IBRAHIMA DIOM"
	cap noisily replace verificateur`x' = "IBRAHIMA S B NDIAYE" if verificateur`x' ==  "IBRAHIMA SIDY B NDIAYE"
	cap noisily replace verificateur`x' = "NDEYE MAREME G CISSE" if verificateur`x' ==  "NDEYE MGCISSE"
	cap noisily replace verificateur`x' = "FATOU NDIAYE" if strpos(verificateur`x', "FATOU") > 0 & strpos(verificateur`x', "LO") > 0
	cap noisily replace verificateur`x' = "IBRAHIMA SIDY BARHAM NDIAYE" if strpos(verificateur`x', "IBRAHIMA") > 0 & strpos(verificateur`x', "S") > 0 & strpos(verificateur`x', "NDIAYE") > 0
	cap noisily replace verificateur`x' = "ISMAILA BEN PAPA DIEME" if strpos(verificateur`x', "ISMA") > 0 & strpos(verificateur`x', "B") > 0 & strpos(verificateur`x', "DIEM") > 0
	cap noisily replace verificateur`x' = "KHADIDIATOU DIALLO GAYE BA" if strpos(verificateur`x', "KHADIJATOU") > 0 & strpos(verificateur`x', "DIALLO") > 0 & strpos(verificateur`x', "GAYE") > 0
	cap noisily replace verificateur`x' = "LAMINE CISSE TOURE" if strpos(verificateur`x', "LAMINE") > 0 & strpos(verificateur`x', "C") > 0 & strpos(verificateur`x', "TOURE") > 0
 	cap noisily replace verificateur`x' = "MAME MASSAR NDIOR NDOUR" if strpos(verificateur`x', "MAME M") > 0 & strpos(verificateur`x', "N") > 0 & strpos(verificateur`x', "NDOUR") > 0
 	cap noisily replace verificateur`x' = "SUZANNE CISSOKHO DIAW" if strpos(verificateur`x', "SUZANNE") > 0 & strpos(verificateur`x', "C") > 0 & strpos(verificateur`x', "DIAW") > 0
 	cap noisily replace verificateur`x' = "NDEYE MAREME GNINGUE CISSE" if strpos(verificateur`x', "NDEYE") > 0 & strpos(verificateur`x', "M") > 0 & strpos(verificateur`x', "CISSE") > 0
 	cap noisily replace verificateur`x' = "NDEYE MAREME GNINGUE CISSE" if strpos(verificateur`x', "NDEYE") > 0 & strpos(verificateur`x', "GNINGUE") > 0 
 	cap noisily replace verificateur`x' = "SUZANNE CISSOKHO DIAW" if strpos(verificateur`x', "SUZANNZ CISSOKHO") > 0 
 	cap noisily replace verificateur`x' = "OUMAR BELLA COLY" if strpos(verificateur`x', "OUMAR BELLE COLY") > 0 
 	cap noisily replace verificateur`x' = "EL HADJI MAMA DIENG" if strpos(verificateur`x', "EL HADJ MAMA DIENG") > 0 
 	cap noisily replace verificateur`x' = "ABDOUL KARIM CAMARA" if strpos(verificateur`x', "ABDOUL K CAMARA") > 0 
 	cap noisily replace verificateur`x' = "ABDOURAHMANE DIOUF" if strpos(verificateur`x', "ABDOURAHMAMNE DIOUF") > 0 
 	cap noisily replace verificateur`x' = "ABDOUL AZIZ DIAGNE" if strpos(verificateur`x', "ABDOUL A") > 0  & strpos(verificateur`x', "DIAGNE") > 0 
 	cap noisily replace verificateur`x' = "ABDOUL SAMB" if strpos(verificateur`x', "ABDOUL SAMBE") > 0 
 	cap noisily replace verificateur`x' = "ARFANG BOURAMA DIEME" if strpos(verificateur`x', "ARFANG B") > 0 
 	cap noisily replace verificateur`x' = "EL ASSANE CISSE MBAYE" if strpos(verificateur`x', "EL ASSANE CISSE MBAY") > 0 
 	cap noisily replace verificateur`x' = "FATOU MAKHA CISSE THIOUNE" if strpos(verificateur`x', "FATOU M") > 0 &  strpos(verificateur`x', "CISSE") > 0 
 	cap noisily replace verificateur`x' = "GORA NDIAYE" if verificateur`x' == "GORA"
 	cap noisily replace verificateur`x' = "GORA NDIAYE" if verificateur`x' == "NDIAYE GORA"	
 	cap noisily replace verificateur`x' = "GORGUI MOUSSA BA" if strpos(verificateur`x', "GORGUI M") > 0 
 	cap noisily replace verificateur`x' = "IBRAHIMA SIDY BARHAM NDIAYE" if strpos(verificateur`x', "IBRAHIMA SIDY B") > 0 
 	cap noisily replace verificateur`x' = "JEANNE ALICE MANCABOU" if strpos(verificateur`x', "JEANNA ALICE MANCABOU") > 0 
 	cap noisily replace verificateur`x' = "ISMAILA PAPE BEN DIEME" if strpos(verificateur`x', "ISMAILA BEN PAPA DIEME") > 0 
 	cap noisily replace verificateur`x' = "BIRANE DIOP" if verificateur`x' == "DIOP BIRANE"
	
 	cap noisily replace verificateur`x' = "MAMADOU N DIOME" if verificateur`x' == "MAMADOU N NDIOME" |  verificateur`x' == "MAMADOU ND DIOME"

}
