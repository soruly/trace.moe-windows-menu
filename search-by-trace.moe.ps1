#Requires -Version 5.1

<#PSScriptInfo
.VERSION 0.1
.GUID 7db8f935-8341-4687-8e7e-7da12448b297
.AUTHOR soruly@gmail.com
.DESCRIPTION search anime screenshot by trace.moe
.PROJECTURI https://github.com/soruly/trace.moe
.LICENSEURI https://raw.githubusercontent.com/soruly/trace.moe/master/LICENSE
#>

param (
  [switch]$install,
  [switch]$uninstall,
  [System.IO.FileInfo]$path
)
$scriptPath = $MyInvocation.MyCommand.Path
$RegistryPath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Search by trace.moe";
if ($install) {
  if (Test-Path $RegistryPath) {
    Remove-Item -Path $RegistryPath -Recurse -Force
  }
  New-Item -Path $RegistryPath -Name 'command' -Force | Out-Null;
  Set-ItemProperty -Path "$RegistryPath\command" -Name '(default)' -Value ('PowerShell -WindowStyle Hidden -File "' + $scriptPath + '" "%V"');
  Set-ItemProperty -Path $RegistryPath -Name '(default)' -Value 'Search by trace.moe';
  Set-ItemProperty -Path $RegistryPath -Name 'Icon' -Value "${Env:WinDir}\System32\shell32.dll,22";
  exit
}
if ($uninstall) {
  if (Test-Path $RegistryPath) {
    Remove-Item -Path $RegistryPath -Recurse -Force
  }
  exit
}
if (-not($path)) {
  write-host "Usage:" $MyInvocation.MyCommand.Name "[-Path <String>] [-Install] [-Uninstall]"
  exit
}
if (-not(Test-Path -LiteralPath $path)) {
  Write-Host "Error: cannot read file " $path
  exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO

[xml]$xaml = @"
<Window 
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  Title="trace.moe" Height="640" Width="640" ResizeMode="NoResize">
    <Grid>
      <Image Name="image" HorizontalAlignment="Left" Height="360" Margin="0,0,0,0" VerticalAlignment="Top" Width="640"/>
      <MediaElement Name="video" HorizontalAlignment="Left" Height="360" Margin="0,0,0,0" VerticalAlignment="Top" Width="640"/>
      <Label Name="titleNative" Content="searching..." HorizontalAlignment="Left" Margin="0,360,0,0" VerticalAlignment="Top"/>
      <Label Name="titleRomaji" Content="" HorizontalAlignment="Left" Margin="0,376,0,0" VerticalAlignment="Top"/>
      <Label Name="timeStamp" Content="" HorizontalAlignment="Left" Margin="0,392,0,0" VerticalAlignment="Top"/>
      <Label Name="similarity" Content="" HorizontalAlignment="Left" Margin="0,408,0,0" VerticalAlignment="Top"/>
      <Label Name="reference" Content="" HorizontalAlignment="Left" Margin="0,424,0,0" VerticalAlignment="Top"/>
    </Grid>
</Window>
"@

$XMLReader = (New-Object System.Xml.XmlNodeReader $xaml)
$form = [Windows.Markup.XamlReader]::Load($XMLReader)

$titleNative = $form.FindName("titleNative")
$titleRomaji = $form.FindName("titleRomaji")
$timeStamp = $form.FindName("timeStamp")
$similarity = $form.FindName("similarity")
$reference = $form.FindName("reference")
$image = $form.FindName("image")
$video = $form.FindName("video")
$video.LoadedBehavior = [System.Windows.Controls.MediaState]::Manual;
$video.Add_MediaEnded({
    $video.Position = New-TimeSpan 0
    $video.Play();
  })

$tempSource = Join-Path $env:TEMP -ChildPath "temp.jpg"
$tempImage = Join-Path $env:TEMP -ChildPath "preview.jpg"
$tempVideo = Join-Path $env:TEMP -ChildPath "preview.mp4"

Copy-Item -LiteralPath $path -Destination $tempSource -Force

Remove-Item -Path $tempImage
Remove-Item -Path $tempVideo

$image.Source = "$path"

$form.Add_ContentRendered({
    $response = Invoke-RestMethod -InFile "$tempSource" -Method Post "https://api.trace.moe/search?anilistInfo"
    Remove-Item -Path $tempSource
    $result = $response.result
    $topResult = $result[0]

    $form.Title = "trace.moe search result"
    $titleNative.Content = $topResult.anilist.title.native
    $titleRomaji.Content = $topResult.anilist.title.romaji
    $timeStamp.Content = [timespan]::fromseconds($topResult.from).tostring("hh\:mm\:ss") + " - " + [timespan]::fromseconds($topResult.to).tostring("hh\:mm\:ss")
    $similarity.Content = ($topResult.similarity).toString("P")
    $reference.Content = $topResult.filename

    $imageUri = New-Object System.Uri ($topResult.image + "&size=l")
    Invoke-WebRequest -URI $imageUri -OutFile $tempImage
    $image.Source = $tempImage

    $videoUri = New-Object System.Uri ($topResult.video + "&size=l")
    Invoke-WebRequest -URI $videoUri -OutFile $tempVideo
    $video.Source = $tempVideo
    $video.Play()
  })

[void]$form.ShowDialog()

$form.Close()
Remove-Item -Force -Path $tempImage
Remove-Item -Force -Path $tempVideo
