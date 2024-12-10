#Requires AutoHotkey v2
#SingleInstance Force
#Include <FindTextV2>
#Include <matFunctionsV2>
#Include <AccV2>
#Include <UIA>

Global SleepTime := 100
Global dia := 0



'::{
    Global Descontos := 0
    Global Auxiliar := 0
    Global Aux := FileOpen("ProLaboreSócios.txt", "r")

    If WinActive("SAN - Contabilidade"){

        WinActive "Lançamentos Contábeis"

        ContwinEl := UIA.ElementFromHandle("SAN - Contabilidade")

        ;getch Mês
        MesO := (ContwinEl.WaitElementFromPath("Y/XIYYr3/").Dump())

        REGEX := "Value:\s`"([^\s]+)"
        Global Mes := RegExFindValue(MesO, REGEX)
        GetDia(Mes)

        ;getch Ano
        AnoO := (ContwinEl.WaitElementFromPath("Y/XIYYr3").Dump())

        REGEX := "Value:\s`"([^\s]+)`""
        Global Ano := RegExFindValue(AnoO, REGEX)
        

        ContwinEl.WaitElementFromPath("Y/XIYYqL0").ControlClick()

        Sleep 400

        Send 1

        If WinActive("Confirmação!"){
            Sleeper("{Enter}",70,1)
        }

        Sleep 175
        Sleeper("{Enter}",70,2)

        Sleep 175
        Send dia

        GetProLabore(Aux)

        while(true){

            WinActive "Lançamentos Contábeis"

            LancaProLabore()

            if(Aux.AtEOF){
                break
            }

            GetProLabore(Aux)

        }
        GetProLaboreGPS()
        LancaGPSProLabore()

        Global VL := PontoVirgula(Descontos)
        Global DC := "INSS S/PRO-LABORE"
        LancaDescontos()

        FileDelete "ProLaboreGPS.txt"
        FileDelete "ProLaboreSócios.txt"
    }
}






^\::{
    SelectedFile := FileSelect(1, "", "Selecione um Arquivo", "All Files (*.*)|*.*")
    Global filePath := SelectedFile

    if SelectedFile = ""{
        MsgBox "Nenhum arquivo foi selecionado.", "Aviso", 48
        Return
    } else{
        ExtraiProLabore(filePath)
        
    }
}


+\::{
    SelectedFile := FileSelect(1, "", "Selecione um Arquivo", "All Files (*.*)|*.*")
    Global filePath := SelectedFile

    if SelectedFile = ""{
        MsgBox "Nenhum arquivo foi selecionado.", "Aviso", 48
        Return
    } else{
        ExtraiFP(filePath)
        
    }
}



\::{

    Global T := true
    Global Aux := FileOpen("Proventos&Descontos.txt", "r")

    If WinActive("SAN - Contabilidade"){

        WinActive "Lançamentos Contábeis"

        ContwinEl := UIA.ElementFromHandle("SAN - Contabilidade")

        ;getch Mês
        MesO := (ContwinEl.WaitElementFromPath("Y/XIYYr3/").Dump())

        REGEX := "Value:\s`"([^\s]+)"
        Global Mes := RegExFindValue(MesO, REGEX)
        GetDia(Mes)

        ;getch Ano
        AnoO := (ContwinEl.WaitElementFromPath("Y/XIYYr3").Dump())

        REGEX := "Value:\s`"([^\s]+)`""
        Global Ano := RegExFindValue(AnoO, REGEX)

        Sleep 175

        ContwinEl.WaitElementFromPath("Y/XIYYqL0").ControlClick()

        Sleep 400

        Send 1
        
        Sleeper("{Enter}",70,1)
        

        Sleep 175

        If WinActive("Confirmação!"){
            Sleeper("{Enter}",70,1)
        }else{

        }
        Sleeper("{Enter}",70,1)

        Sleep 175
        Send dia

        Get(Aux)

        while(true){
            If WinExist("SAN - Contabilidade"){

                WinActive "Lançamentos Contábeis"

                if(GrupoSalario()){

                    LancaSalario()

                }
                else if(GrupoINSS()){

                    LancaINSS()

                }
                else if(GrupoFerias()){

                    LancaFerias()
                }
                else if(Grupo13()){

                    Lanca13()

                }
                else if(GrupoSalarioMaternidade()){

                    LancaMaternidade()

                }
                else if(GrupoFalta()){

                    LancaFalta()

                }
                else if(GrupoLiquidoRecisao()){

                    LancaLiquidoRecisao()

                }
                else if(GrupoLiquidoFerias()){

                    LancaLiquidoFerias()

                }
                else if(GrupoContribuicao()){

                    LancaContribuicao()

                }
                else if(GrupoPensao()){

                    LancaPensao()

                }

                if(Aux.AtEOF){
                    break
                }

                Get(Aux)
            }
        }
        LancaFGTS()

        FileDelete "GPSNormal.txt"
        FileDelete "FGTSMensal.txt"
        FileDelete "Proventos&Descontos.txt"
    }
}


;Extrai a linha a partir da linha Proventos & Descontos
ExtraiFP(arq) {
    Aux := FileOpen(arq, "r")
    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaProventosDescontos(Linha)) {
            Break
        }

    }
    Aux2 := FileOpen("Proventos&Descontos.txt", "w", "CP1252")


    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()
        pipe := StrSplit(Linha, "|")

        if (LinhaValida(Linha)) {
            if(pipe[2] != "                                                              "){
                Aux2.WriteLine(pipe[2])
            }
            if(pipe[3] != "                                                             "){
                Aux2.WriteLine(pipe[3])
            }
        }
    }
    Aux.Close()
    Aux2.Close()

    ExtraiFGTS(arq)

}

;Extrai a linha a partir do FGTS Mensal
ExtraiFGTS(arq) {
    Aux := FileOpen(arq, "r")

    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaFGTSMensal(Linha)) {
            Break
        }

    }
    Aux2 := FileOpen("FGTSMensal.txt", "w", "CP1252")


    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()
        pipe := StrSplit(Linha, "|")

        if (!ParadaFGTS(Linha)) {
            Aux2.WriteLine(pipe[2])
        }else{
            break
        }
    }
    Aux.Close()
    Aux2.Close()

    ExtraiGPS(arq)
}

;Extrai a linha a partir do GPS
ExtraiGPS(arq) {
    Aux := FileOpen(arq, "r")
    Aux2 := FileOpen("GPSNormal.txt", "w", "CP1252")


    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaValidaGPS(Linha)) {
            Aux2.WriteLine(Linha)
        }
    }
    Aux.Close()
    Aux2.Close()

}


;Pro Labore
ExtraiProLabore(arq) {
    ;Nome;Salário Liquido;Desconto
    Aux := FileOpen(arq, "r")
    Aux2 := FileOpen("ProLaboreSócios.txt", "w", "CP1252")


    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaNomeProLabore(Linha)) {
            ;Nome
            Aux2.Write(RegExFindValue(Linha, "\|\s[Cod]+:\s[\d]+\s+Nome:([\wÀ-ÿ ]+?)(?=\s{2})\s+Dep.IR:\s+\d\s\|") ";")
        }
        if(LinhaLiquidoProLabore(Linha)){
            ;Salário Liquido
            Aux2.Write(RegExFindValue(Linha, "\|\sProventos:\s+[\d.,]+\s+Descontos:\s+[\d.,]+\s+Liquido:\s+([\d.,]+)\s\|") ";")
            ;Descontos
            Aux2.Write(RegExFindValue(Linha, "\|\sProventos:\s+[\d.,]+\s+Descontos:\s+([\d.,]+)\s+Liquido:\s+[\d.,]+\s\|") "`n")

        }
    }
    Aux.Close()
    Aux2.Close()

    ;GPS
    Aux := FileOpen(arq, "r")
    Aux2 := FileOpen("ProLaboreGPS.txt", "w", "CP1252")

    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaGPSProLabore(Linha)) {
            Aux2.WriteLine(RegExFindValue(Linha, "\|\sCod.\s\d+\s+Empresa\s+([\d.,]+)\s+"))

            break
        }
    }

}



;Extrai os valores necessarios
Get(Aux) {
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        if (Linha != "") { ; Verifica se a linha foi lida corretamente
            Global DC := RegExFindValue(Linha, "^\s+\d+\s([\wÀ-ÿ()º\.\/%\- ]+?)(?=\s{3})")
            Global VL := RegExFindValue(Linha, "\s+([.,\d]+)\s$")
            Global VL := pontoNada(VL)
            if(VL == 0,00){
                Get(Aux)
            }
        }
    } else if(Aux.AtEOF){
        MsgBox "TODOS OS LANÇAMENTOS RESPECTIVOS FORAM FEITOS.", "Aviso", 48
        Aux.Close()
    }

}

GetFGTS(Aux) {
    Global DC := "FGTS"
    while (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        if (Linha != "") { ; Verifica se a linha foi lida corretamente
            if(RegExMatch(Linha, "\d{2}\sF\.G\.T\.S\.:\s+([\d.,]+)\s",&match)){
                Global VL := RegExFindValue(Linha, "\d{2}\sF\.G\.T\.S\.:\s+([\d.,]+)\s")
                Global VL := pontoNada(VL)
            }
        }
    } else if(Aux.AtEOF){
        MsgBox "TODOS OS LANÇAMENTOS DO FGTS MENSAL FORAM FEITOS.", "Aviso", 48
        Aux.Close()
    }

}

GetGPS(Aux) {
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        if (Linha != "") { ; Verifica se a linha foi lida corretamente
            Global DC :="INSS " RegExFindValue(Linha, "\|\s[\wÀ-ÿ\.]+\s\d+\s+(\w+)\s+[\d.,]+[^|]+\|")
            Global VL := RegExFindValue(Linha, "\|\s[\wÀ-ÿ\.]+\s\d+\s+\w+\s+([\d.,]+)[^|]+\|")
            Global VL := pontoNada(VL)

        }
    } else if(Aux.AtEOF){
        MsgBox "TODOS OS LANÇAMENTOS DO INSS FORAM FEITOS.", "Aviso", 48
        Aux.Close()
    }

}


;Get Pro Labore
GetProLabore(Aux){

    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        pipe := StrSplit(Linha, ";")

        Global DC := "PRO-LABORE " pipe[1]
        Global VL := pipe[2]
        Global VL := pontoNada(VL)
        ;Descontos
        Global Auxiliar := pipe[3]
        Global Auxiliar := pontoNada(Auxiliar)
        Global Auxiliar := VirgulaPonto(Auxiliar)
        Global Descontos += Auxiliar + 0

        
    } else if(Aux.AtEOF){
        MsgBox "TODOS OS LANÇAMENTOS RESPECTIVOS FORAM FEITOS.", "Aviso", 48
        Aux.Close()
    }
    
}

GetProLaboreGPS(){
    ;GPS Pro Labore
    Aux := FileOpen("ProLaboreGPS.txt", "r")
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        Global DC := "INSS"
        Global VL := Linha
        Global VL := pontoNada(VL)
    }
    Aux.Close()
}


;Lançamentos
LancaFGTS(){
    Global Aux := FileOpen("FGTSMensal.txt", "r")
    GetFGTS(Aux)
        
    LancarFGTS()
    
    LancaGPS()
}

LancaGPS(){
    Global T := true
    Global Aux := FileOpen("GPSNormal.txt", "r")
    Aux.ReadLine()
    while(true){

        GetGPS(Aux)
        LancarGPS()
        if(Aux.AtEOF){
            break
        }
    }
    GetGPS(Aux)
}

LancaSalario(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(2,70,1)
    Sleep 20
    Sleeper(0,70,1)
    Sleep SleepTime
    Sleeper(069,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime

    
    Resto()
    

}

LancaINSS(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(065,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    
    Resto()

}

LancarGPS(){
    
    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,3)
    Sleep 20
    Sleeper(11,70,1)
    Sleep 20
    Sleeper(0,70,1)
    Sleep SleepTime
    Sleeper(065,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime

    
    Resto()
    
}

LancarFGTS(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,3)
    Sleep 20
    Sleeper(13,70,1)
    Sleep 20
    Sleeper(0,70,1)
    Sleep SleepTime
    Sleeper(065,70,1)
    Sleep SleepTime

    Sleeper(0,40,3)
    Sleep 20
    Sleeper(51,70,1)
    Sleep SleepTime

    
    Resto()
}

LancaFerias(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime
    Sleeper(0,40,3)
    Sleep 20
    Sleeper(14,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    
    Resto()

}

Lanca13(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime
    Sleeper(0,40,3)
    Sleep 20
    Sleeper(20,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaMaternidade(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(065,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaFalta(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(139,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(2,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaLiquidoRecisao(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime

    Sleeper(0,70,1)
    Sleep 20
    Sleeper(11,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(3,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaLiquidoFerias(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(11,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep 20
    Sleeper(5,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaContribuicao(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep SleepTime
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(065,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep SleepTime
    Sleeper(3,70,1)
    Sleep SleepTime
    
    Resto()

}

LancaPensao(){

    ;Regra
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep SleepTime
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,1)
    Sleep 20
    Sleeper(069,70,1)
    Sleep SleepTime
    Sleeper(0,40,4)
    Sleep SleepTime
    Sleeper(5,70,1)
    Sleep SleepTime
    
    Resto()

}

;Lançamentos Pro Labore
LancaGPSProLabore(){
    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,3)
    Sleep 20
    Sleeper(11,70,1)
    Sleep 20
    Sleeper(0,70,1)
    Sleep SleepTime
    Sleeper(065,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime

    
    Resto()
}

LancaDescontos(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep 20
    Sleeper(0,70,1)
    Sleep SleepTime
    Sleeper(065,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime

    
    Resto()

}

LancaProLabore(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,70,2)
    Sleeper(001,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(1,70,1)
    Sleep SleepTime
    Sleeper(0,40,2)
    Sleep 20
    Sleeper(151,70,1)
    Sleep SleepTime
    ;Descrição
    Sleeper(DC,70,1)
    Sleep SleepTime
    Sleeper(" ",40,1)
    Sleep 20
    ;Data
    Sleeper(Mes,70,1)
    Sleep 20
    Sleeper("/",40,1)
    Sleep 20
    Sleeper(Ano,70,1)
    Sleep SleepTime
    ;Value
    Sleeper("{Tab}",70,1)
    Sleep SleepTime
    Sleeper(VL,70,1)
    Sleep SleepTime
    Sleeper("{Tab}",70,1)
    Sleep SleepTime

    Sleeper("!o",70,1)
    Sleep SleepTime
    Sleeper("{Tab}",70,1)
}


;Ultimo dia correto para o mês referente
GetDia(mes){
    switch(mes){
        case 01:
            Global dia := 31
        case 02:
            Global dia := 28
        case 03:
            Global dia := 31
        case 04:
            Global dia := 30
        case 05:
            Global dia := 31
        case 06:
            Global dia := 30
        case 07:
            Global dia := 31
        case 08:
            Global dia := 31
        case 09:
            Global dia := 30
        case 10:
            Global dia := 31
        case 11:
            Global dia := 30
        case 12:
            Global dia := 31
    }
}


;Resto do Lançamento
Resto(){

    Sleeper(0,40,2)
    Sleep 20
    Sleeper(800,70,1)
    Sleep SleepTime
    ;Descrição
    Sleeper(DC,70,1)
    Sleep SleepTime
    Sleeper(" ",40,1)
    Sleep 20
    ;Data
    Sleeper(Mes,70,1)
    Sleep 20
    Sleeper("/",40,1)
    Sleep 20
    Sleeper(Ano,70,1)
    Sleep SleepTime
    ;Value
    Sleeper("{Tab}",70,1)
    Sleep SleepTime
    Sleeper(VL,70,1)
    Sleep SleepTime
    Sleeper("{Tab}",70,1)
    Sleep SleepTime

    Sleeper("!o",70,1)
    Sleep SleepTime
    Sleeper("{Tab}",70,1)

}

;Da match com a linha que começa com uma data, quando os dias trocam
LinhaProventosDescontos(Linha) {
    return RegExMatch(Linha, "\s+(Proventos)\s+[^ ]+\s+(Descontos)\s+", &match)
}
LinhaFGTSMensal(Linha) {
    return RegExMatch(Linha, "\s+(FGTS)\s(Mensal\s\(Recolhimento SEFIP)\)\s+", &match)
}
LinhaGPS(Linha) {
    return RegExMatch(Linha, "\|G\s+G\sP\sS\s+H\|", &match)
}

ParadaFGTS(Linha) {
    return RegExMatch(Linha, "\s+F G T S\sRescisorio\s\(Recolhimento GRRF\)\s+", &match)
}

;Da match com a linha que começa com uma data, quando os dias trocam
LinhaValida(Linha) {
    return RegExMatch(Linha, "\|\s+\d+\s[^\|]+", &match)
}
LinhaValidaFGTS(Linha) {
    return RegExMatch(Linha, "\|\s\w+\s[^\|;\/%-]+\|", &match)
}
LinhaValidaGPS(Linha) {
    return RegExMatch(Linha, "\|\s[\wÀ-ÿ\.]+\s\d+\s+\w+\s+[\d.,]+[^|]+\|", &match)
}
;Pro Labore

LinhaNomeProLabore(Linha) {
    return RegExMatch(Linha, "\|\s[Cod]+:\s[\d]+\s+Nome:[\wÀ-ÿ ]+\sDep.IR:\s+\d\s\|", &match) 
}
LinhaLiquidoProLabore(Linha) {
    return RegExMatch(Linha, "\|\sProventos:\s+[\d.,]+\s+Descontos:\s+[\d.,]+\s+Liquido:\s+[\d.,]+\s\|", &match) 
}
LinhaGPSProLabore(Linha) {
    return RegExMatch(Linha, "\|\sCod.\s\d+\s+Empresa\s+[\d.,]+\s+", &match) 
}




;Verifica em que grupo pertence o lançamento
GrupoSalario() {
    return DC == "Salário" || DC == "Adicional Insalubridade" || DC == "Saldo de Salário" || DC == "Horas Extras 60%" || DC == "Dia do Comerciario" || DC == "Aviso Prévio Indenizado" || DC == "Aviso Prévio - Lei 12.506/11" || DC == "Diferença Salarial"
}

GrupoINSS() {
    return DC == "INSS Sobre Salário" || DC == "IRRF Sobre Salário" || DC == "INSS Sobre Salário (Rescisão)" || DC == "INSS Sobre 13º Sal. (Rescisão)" || DC == "IRRF Descontado nas Férias" || DC == "INSS Férias Mês -Recibo"
}

GrupoFerias() {
    return DC == "Férias Vencidas (Aqs1)" || DC == "Férias Proporcionais" || DC == "1/3 de Férias Indenizadas" || DC == "Férias Proporc. Indenizadas" || DC == "1/3 Férias Propor Indenizadas" || DC == "Férias No Mês" || DC == "1/3 de Férias no Mês" || DC == "Diferença de Ferias"
}

Grupo13() {
    return DC == "13º Salário Proporcional" || DC == "13º Salário Indenizado" || DC == "13º Sal Proporc Maternidade" || DC == "13º Indenizado Lei 12.506/11"
}

GrupoSalarioMaternidade() {
    return DC == "Salário Maternidade" || DC == "Salário Família"
}

GrupoFalta() {
    return DC == "Faltas (Dias)" || DC == "Farmácia" || DC == "Vale  Compras" || DC == "Seguro de Vida" || DC == "Adiantamento" || DC == "Empréstimo" || DC == "Arredondamento Anterior" || DC == "Aviso Previo Descontado"
}

GrupoLiquidoRecisao() {
    return DC == "Liquido de Rescisão" || DC == "Adiantamento Anterior"
}

GrupoLiquidoFerias() {
    return DC == "Liquido de Férias"
}

GrupoContribuicao() {
    return DC == "Contribuição Assistencial"
}

GrupoPensao() {
    return DC == "Pensão Alimenticia Salário" || DC == "Pensão Alimenticia"
}
