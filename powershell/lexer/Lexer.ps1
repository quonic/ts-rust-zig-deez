function Invoke-ParseTokens {
    param(
        [string]$InputText
    )
    begin {
        enum Tokens {
            Ident
            Integer
            Let
            Illegal
            Eof
            Equal
            Plus
            Comma
            Semicolon
            LParen
            RParen
            LSquirly
            RSquirly
            Function
            String
            Identifier
        }
    }
    process {
        $ErrorActionPreference = 'Stop'
        $position = 0
        while ($position -lt $InputText.Length) {
            $c = $InputText[$position]
            
            if ([char]::IsWhiteSpace($c)) {
                $position++
                continue
            }
            
            if ([char]::IsLetter($c)) {
                $start = $position
                while (
                    $position -lt $InputText.Length -and
                    $(
                        [char]::IsLetterOrDigit($InputText[$position]) -or
                        $InputText[$position] -like '_'
                    )
                ) {
                    $position++
                }

                $value = $InputText.Substring($start, $position - $start)
                $token = switch ($value) {
                    "let" { [Tokens]::Let }
                    "fn" { [Tokens]::Function }
                    "_" { [Tokens]::Identifier }
                }
                [PSCustomObject]@{
                    Tokens = $token
                    Value  = $value
                }
                continue
            }
            
            if ([char]::IsDigit($c)) {
                $start = $position

                while ($position -lt $InputText.Length -and [char]::IsDigit($InputText[$position])) {
                    $position++
                }

                $value = $InputText.Substring($start, $position - $start)
                [PSCustomObject]@{
                    Tokens = [Tokens]::Integer
                    Value  = [int]$value
                }
                continue;
            }

            if ($c -like '\"') {
                $start = $position + 1 # Skip the opening quote
                $position++

                while ($position -lt $InputText.Length -and $InputText[$position] -notlike '\"') {
                    $position++
                }

                if ($position -ge $InputText.Length) {
                    throw "Unterminated string literal."
                }

                $value = $InputText.Substring($start, $position - $start);
                $position++ # Skip the closing quote

                [PSCustomObject]@{
                    Tokens = [Tokens]::String
                    Value  = $value
                }
                $position++
                continue
            }
            
            #Single char tokens
            switch ($c) {
                '=' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::Equal
                        Value  = '='
                    }
                }
                '+' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::Plus
                        Value  = '+'
                    }
                }
                ',' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::Comma
                        Value  = ','
                    }
                }
                ';' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::Semicolon
                        Value  = ';'
                    }
                }
                '(' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::LParen
                        Value  = '('
                    }
                }
                ')' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::RParen
                        Value  = ')'
                    }
                }
                '{' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::LSquirly
                        Value  = '{'
                    }
                }
                '}' {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::RSquirly
                        Value  = '}'
                    }
                }
                default {
                    [PSCustomObject]@{
                        Tokens = [Tokens]::Illegal
                        Value  = $c
                    }
                }
            }
            $position++
        }
    
        [PSCustomObject]@{
            Tokens = [Tokens]::Eof
            Value  = $null
        }
        $ErrorActionPreference = 'Continue'
    }
}