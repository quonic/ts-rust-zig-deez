Describe "TypeScript Lexer" {
    BeforeAll {
        # Dot source, "Import"
        . .\lexer\Lexer.ps1
    }
    Context "Parse" {
        It "Correctly Parses" {
            $testInput = @"
let five = 5;
let ten = 10;
let add = fn(x, y) {
    x + y;
};
let result = add(five, ten);
"@

            $tokens = Invoke-ParseTokens -InputText $testInput

            $tokens.Count | Should -Be 37
            $TokenText = $($tokens.Value -join ' ' -replace ' ;', ';' -replace 'fn \(', 'fn(' -replace ' x , y \) \{ x \+ y;', 'x, y) { x + y;' -replace 'add \( five , ten \)', 'add(five, ten)').Trim()
            $TestText = $($testInput -split "`r`n" | ForEach-Object { $_.Trim() }) -join ' '
            $TokenText | Should -Be $TestText
        }
    }
}