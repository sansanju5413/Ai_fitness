# Test Gemini API Key
# Run this script to verify your API key works

$apiKey = "AIzaSyDzBOw_A8ThYiE3MSSjESAjLfAQPFnRVZM"
$uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey"

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "Say hello in exactly one word"
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $body
    Write-Host "✅ API Key is WORKING!" -ForegroundColor Green
    Write-Host "Response: $($response.candidates[0].content.parts[0].text)"
} catch {
    Write-Host "❌ API Key ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message
    }
}
