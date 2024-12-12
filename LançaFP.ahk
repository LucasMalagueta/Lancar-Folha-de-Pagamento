#Requires AutoHotkey v2
#SingleInstance Force
#Include <FindTextV2>
#Include <matFunctionsV2>
#Include <AccV2>
#Include <UIA>
TraySetIcon("C:\Users\" A_Username "\Documents\AutoHotkey\Lib\pngwing.com.ico")

Global SleepTime := 100
Global dia := 0
GLobal MORIELET := "NULL"


OnEventDefinir(*){

    Global SelectedFiles := FileSelect("M1", "", "Selecione um arquivo", "TXT (*.txt)")

    if (SelectedFiles.Length = 0) {
        MsgBox "Nenhum arquivo foi selecionado.", "Aviso", 48
        Return
    }
    

    for file in SelectedFiles {

        if(RegExMatch(file,"(Folha de Pagamento -Normal).+\.txt",&match)){
            GetNomeEmpresa(file)
            ExtraiFP(file)
            ExtraiFGTS(file)
            ExtraiGPS(file)
            continue
        }
        if(RegExMatch(file,"(Folha de Pro Labore).+\.txt",&match)){
            ExtraiProLabore(file)
            continue
        }
        if(RegExMatch(file,"(Folha de Autonomo).+\.txt",&match)){
            ExtraiAutonomo(file)
            continue
        }
    }
}


OnEventLancar(*){


    if(DropDownList1.text == "Folha Normal"){


        Global T := true
        Global Aux := FileOpen("DOC/Proventos&Descontos.txt", "r")
        WinActivate("SAN - Contabilidade")

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
                    else if(GrupoDesc13()){

                        LancaDescontos13()

                    }

                    if(Aux.AtEOF){
                        break
                    }

                    Get(Aux)
                }
            }
            LancaFGTS()
        }

    }
    else if(DropDownList1.text == "Pró-Labore"){
        Global Descontos := 0
        Global Auxiliar := 0
        Global Aux := FileOpen("DOC/ProLaboreSócios.txt", "r")
        WinActivate("SAN - Contabilidade")

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
            
            Sleeper("{Enter}",70,1)
            

            Sleep 175

            If WinActive("Confirmação!"){
                Sleeper("{Enter}",70,1)
            }else{

            }
            Sleeper("{Enter}",70,1)

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

        }
    }
    else if(DropDownList1.text == "Autônomos"){
        Global Descontos := 0
        Global Auxiliar := 0
        Global Aux := FileOpen("DOC/Autonomos.txt", "r")
        WinActivate("SAN - Contabilidade")

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
            
            Sleeper("{Enter}",70,1)
            

            Sleep 175

            If WinActive("Confirmação!"){
                Sleeper("{Enter}",70,1)
            }else{

            }
            Sleeper("{Enter}",70,1)

            Sleep 175
            Send dia

            GetAutonomo(Aux)

            while(true){

                WinActive "Lançamentos Contábeis"

                LancaAutonomo()

                if(Aux.AtEOF){
                    break
                }

                GetAutonomo(Aux)

            }
            GetAutonomoGPS()
            LancaGPSProLabore()

            Global VL := PontoVirgula(Descontos)
            Global DC := "INSS S/Hon. Contábeis"
            LancaDescontosAutonomo()

        }
    }
}

GetNomeEmpresa(arq){

    Aux := FileOpen(arq,"r")
    while(!(Aux.AtEOF)){
        Linha := Aux.ReadLine()

        if(RegExMatch(Linha, "\|\sApelido:\s+\w+\s+Razao Social:\s+[^Pag]+Pag:1\|", &match)){

            Global NomeEmpresa := RegExFindValue(Linha,"\|\sApelido:\s+([\w]+)\s+Razao Social:\s+[^Pag]+Pag:1\|")
        }
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
    Aux2 := FileOpen("DOC/Proventos&Descontos.txt", "w", "CP1252")


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
    Aux2 := FileOpen("DOC/FGTSMensal.txt", "w", "CP1252")


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

}

;Extrai a linha a partir do GPS
ExtraiGPS(arq) {
    Aux := FileOpen(arq, "r")
    Aux2 := FileOpen("DOC/GPSNormal.txt", "w", "CP1252")


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
    Aux2 := FileOpen("DOC/ProLaboreSócios.txt", "w", "CP1252")


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
    Cor := FileOpen(arq, "r")
    Cor2 := FileOpen("DOC/ProLaboreGPS.txt", "w", "CP1252")

    while (!(Cor.AtEOF)) {
        Linha := Cor.ReadLine()

        if (LinhaGPSProLabore(Linha)) {
            Cor2.WriteLine(RegExFindValue(Linha, "\|\sCod.\s\d+\s+Empresa\s+([\d.,]+)\s+"))

            break
        }
    }
    Cor.Close()
    Cor2.Close()

}

ExtraiAutonomo(arq) {
    ;Nome;Salário Liquido;Desconto
    Aux := FileOpen(arq, "r")
    Aux2 := FileOpen("DOC/Autonomos.txt", "w", "CP1252")


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
    Aux2 := FileOpen("DOC/AutonomosGPS.txt", "w", "CP1252")

    while (!(Aux.AtEOF)) {
        Linha := Aux.ReadLine()

        if (LinhaGPSProLabore(Linha)) {
            Aux2.WriteLine(RegExFindValue(Linha, "\|\sCod.\s\d+\s+Empresa\s+([\d.,]+)\s+"))

            break
        }
    }

    Aux.Close()
    Aux2.Close()

}



;Extrai os valores necessarios
Get(Aux) {
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        if (Linha != "") { ; Verifica se a linha foi lida corretamente
            Global DC := RegExFindValue(Linha, "^\s+\d+\s([\wÀ-ÿ()º\.\/%\- ª]+?)(?=\s{3})")
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

        Global DC := "PRÓ-LABORE " pipe[1]
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
    Aux := FileOpen("DOC/ProLaboreGPS.txt", "r")
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        Global DC := "INSS"
        Global VL := Linha
        Global VL := pontoNada(VL)
    }
    Aux.Close()
}

;Get Autônomos
GetAutonomo(Aux){

    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        pipe := StrSplit(Linha, ";")

        Global DC := "Autônomo " pipe[1]
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

GetAutonomoGPS(){
    ;GPS Pro Labore
    Aux := FileOpen("DOC/AutonomosGPS.txt", "r")
    if (!Aux.AtEOF) {
        Linha := Aux.ReadLine()
        Global DC := "INSS S/AUTONOMO"
        Global VL := Linha
        Global VL := pontoNada(VL)
    }
    Aux.Close()
}


;Lançamentos
LancaFGTS(){
    Global Aux := FileOpen("DOC/FGTSMensal.txt", "r")
    GetFGTS(Aux)
        
    LancarFGTS()
    
    LancaGPS()
}

LancaGPS(){
    Global Aux := FileOpen("DOC/GPSNormal.txt", "r")
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

LancaDescontos13(){

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
    Sleeper(4,70,1)
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
    if(NomeEmpresa == "MORIELET"){
        Sleeper(6,70,1)
    }else{
        Sleeper(5,70,1)
    }
    Sleep SleepTime
    
    Resto()

}
;Lançamentos Pro Labore

LancaAutonomo(){
    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(6,70,1)
    Sleep 20
    Sleeper(0,70,2)
    Sleep SleepTime
    Sleeper(1,70,1)
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
LancaDescontosAutonomo(){

    ;Regra
    Sleeper(139,70,1)
    Sleep SleepTime

    Sleeper(0,40,4)
    Sleep 20
    Sleeper(6,70,1)
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
    return DC == "Salário" || DC == "Adicional Insalubridade" || DC == "Saldo de Salário" || DC == "Horas Extras 60%" || DC == "Dia do Comerciario" || DC == "Aviso Prévio Indenizado" || DC == "Aviso Prévio - Lei 12.506/11" || DC == "Diferença Salarial" || DC == "Quebra de Caixa" || DC == "Adicional Periculosidade" || DC == "Adicional Noturno 25%" || DC == "Horas Extras 50%" || DC == "Horas Extras 100%" || DC == "Adicional Noturno valor" || DC == "D.S.R. Sobre Horas Extras" || DC == "DSR Adicional Noturno" || DC == "Salário Afast Pago Empregador" || DC == "Adicional Noturno 35%" || DC == "Horas Extras 80%"
}

GrupoINSS() {
    return DC == "INSS Sobre Salário" || DC == "IRRF Sobre Salário" || DC == "INSS Sobre Salário (Rescisão)" || DC == "INSS Sobre 13º Sal. (Rescisão)" || DC == "IRRF Descontado nas Férias" || DC == "INSS Férias Mês -Recibo" || DC == "INSS Férias Mês Anterior"
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
    return DC == "Faltas (Dias)" || DC == "Farmácia" || DC == "Vale  Compras" || DC == "Seguro de Vida" || DC == "Adiantamento" || DC == "Empréstimo" || DC == "Arredondamento Anterior" || DC == "Aviso Previo Descontado" || DC == "Abono Pecuniário Mês Anterior" || DC == "1/3 Abono Pecuniário Mês Ant." || DC == "Emprestimo" || DC == "Vale Transportes" || DC == "Vale Transportes" || DC == "Artigo 480 CLT" || DC == "Plano de Saúde" || DC == "Faltas DSR (Dias)" || DC == "Faltas / Atrasos DSR (Horas)"
}

GrupoLiquidoRecisao() {
    return DC == "Liquido de Rescisão" || DC == "Adiantamento Anterior"
}

GrupoLiquidoFerias() {
    return DC == "Liquido de Férias" || DC == "Férias Pagas Mês Anterior" || DC == "Liquido Férias Mês Anterior" || DC == "1/3 Ferias Pagas Mês Anterior"
}

GrupoContribuicao() {
    return DC == "Contribuição Assistencial"
}

GrupoPensao() {
    return DC == "Pensão Alimenticia Salário" || DC == "Pensão Alimenticia" || DC == "Pensão Sobre Salário Minimo"
}

GrupoDesc13(){
    return DC == "Desc. 1ª Parcela 13º Salário"
}





;Chama a interface grafica (GUI)
+1:: {
    if WinExist("Lança FP") {
        WinClose("")
    }

     myGui := Construct()

    Construct() {
        Global myGui := Gui() ; Mantém a janela no topo.

        ; Estilo e título
        myGui.BackColor := "White" ; Fundo branco
        myGui.Title := "Lança FP"

        ; Título principal
        myGui.SetFont("Bold s13", "Segoe UI")
        myGui.Add("Text", "x32 y16 w424 h21 +Center BackgroundTrans cf5821f", "Lança FP")

        ; Lista de seleção
        myGui.SetFont("s10", "Segoe UI")
        myGui.Add("Text", "x26 y80 w120 h20 BackgroundTrans", "Lançamento tipo:")
        Global DropDownList1 := myGui.Add("DropDownList", "x150 y78 w200 Border choose1  cBlack", ["Folha Normal", "Pró-Labore", "Autônomos"])

        ; Botões
        ButtonDefinirCaminhoNFE := myGui.Add("Button", "x16 y160 w220 h40 Border BackgroundGray", "&Selecionar Arquivo")
        ButtonLancar := myGui.Add("Button", "x248 y160 w220 h40 Border BackgroundGray", "&Lançar")

        ; Rodapé
        myGui.SetFont("s8", "Segoe UI")
        myGui.Add("Text", "x16 y229 w454 h20 +Center BackgroundTrans cGray", "Desenvolvido por Lucas Malagueta")

        ; Eventos dos botões
        ButtonDefinirCaminhoNFE.OnEvent("Click", OnEventDefinir)
        ButtonLancar.OnEvent("Click", OnEventLancar)

        ; Evento para fechar
        myGui.OnEvent("Close", (*) => myGui.Destroy())

        ; Exibe a GUI
        myGui.Show("w484 h250")

        Return myGui
    }
}

; myGui.Add("Text", "x32 y16 w424 h21 +Center", "Lança FP")
; myGui.Add("Text", "x26 y80 w120 h20", "Lançamento tipo:")
; DropDownList1 := myGui.Add("DropDownList", "x150 y78 w200", ["Folha Normal", "Pró-Labore", "Autônomos"])
; ButtonSelecionarArquivo := myGui.Add("Button", "x16 y152 w220 h40", "&Selecionar Arquivo")
; ButtonLanar := myGui.Add("Button", "x248 y152 w220 h40", "&Lançar")
; myGui.Add("Text", "x16 y229 w454 h20 +Center", "Desenvolvido por Lucas Malagueta")
; DropDownList1.OnEvent("Change", OnEventHandler)
; ButtonSelecionarArquivo.OnEvent("Click", OnEventHandler)
; ButtonLanar.OnEvent("Click", OnEventHandler)
; myGui.OnEvent('Close', (*) => ExitApp())
; myGui.Title := "Lança FP (Clone)"
; myGui.Show("w484 h250")