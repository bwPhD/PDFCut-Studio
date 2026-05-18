param([switch]$SelfTest)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml

$AppDir = Split-Path -Parent $PSCommandPath
$RootDir = Split-Path -Parent $AppDir
$Java = Join-Path $RootDir 'runtime\bin\java.exe'
$Javaw = Join-Path $RootDir 'runtime\bin\javaw.exe'
$Jar = Join-Path $RootDir 'lib\Briss-2.0-all.jar'
$OutputDir = Join-Path $RootDir 'output'
$Guide = Join-Path $RootDir 'docs\QUICK_START.md'
$AppVersion = '1.0.0'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Assert-Runtime {
    if (-not (Test-Path -LiteralPath $Java) -or -not (Test-Path -LiteralPath $Javaw)) {
        throw 'Bundled Java runtime is missing.'
    }
    if (-not (Test-Path -LiteralPath $Jar)) {
        throw 'Briss-2.0-all.jar is missing.'
    }
}

function Quote-Arg([string]$Value) {
    '"' + ($Value -replace '"', '\"') + '"'
}

function Join-ProcessArgs([string[]]$Values) {
    ($Values | ForEach-Object { Quote-Arg $_ }) -join ' '
}

function Ui([string]$Text) {
    [System.Net.WebUtility]::HtmlDecode($Text)
}

function L([string]$ZhText, [string]$EnText) {
    if ($script:Language -eq 'en') {
        return $EnText
    }
    return (Ui $ZhText)
}

function Set-ControlText([string]$Name, [string]$EnglishText) {
    $control = $window.FindName($Name)
    if ($null -eq $control) {
        return
    }
    if (-not $script:ChineseText.ContainsKey($Name)) {
        if ($control.PSObject.Properties.Name -contains 'Text') {
            $script:ChineseText[$Name] = $control.Text
        } elseif ($control.PSObject.Properties.Name -contains 'Content') {
            $script:ChineseText[$Name] = $control.Content
        }
    }

    $value = $EnglishText
    if ($script:Language -eq 'zh') {
        $value = $script:ChineseText[$Name]
    }

    if ($control.PSObject.Properties.Name -contains 'Text') {
        $control.Text = $value
    } elseif ($control.PSObject.Properties.Name -contains 'Content') {
        $control.Content = $value
    }
}

function Set-Status {
    param(
        [string]$ZhText,
        [string]$EnText,
        [string]$Tone = 'Neutral'
    )
    $script:LastStatusZh = $ZhText
    $script:LastStatusEn = $EnText
    $script:StatusText.Text = L $ZhText $EnText
    switch ($Tone) {
        'Good' {
            $script:StatusDot.Fill = '#14B8A6'
            $script:StatusText.Foreground = '#0F766E'
        }
        'Warn' {
            $script:StatusDot.Fill = '#F59E0B'
            $script:StatusText.Foreground = '#92400E'
        }
        'Busy' {
            $script:StatusDot.Fill = '#2563EB'
            $script:StatusText.Foreground = '#1D4ED8'
        }
        default {
            $script:StatusDot.Fill = '#64748B'
            $script:StatusText.Foreground = '#475569'
        }
    }
}

function Set-SelectedPdf([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return
    }
    if ([IO.Path]::GetExtension($Path).ToLowerInvariant() -ne '.pdf') {
        Set-Status '&#x8BF7;&#x9009;&#x62E9; PDF &#x6587;&#x4EF6;&#x3002;' 'Please choose a PDF file.' 'Warn'
        return
    }
    $script:SelectedPdf = (Resolve-Path -LiteralPath $Path).Path
    $script:FileNameText.Text = [IO.Path]::GetFileName($script:SelectedPdf)
    $script:FilePathText.Text = $script:SelectedPdf
    $script:DropTitle.Text = L '&#x5DF2;&#x9009;&#x62E9; PDF' 'PDF selected'
    Set-Status '&#x6587;&#x4EF6;&#x5DF2;&#x5C31;&#x7EEA;&#xFF0C;&#x53EF;&#x76F4;&#x63A5;&#x6253;&#x5F00;&#x53EF;&#x89C6;&#x5316;&#x88C1;&#x526A;&#x3002;' 'File ready. Open Visual Crop to continue.' 'Good'
}

function Choose-Pdf {
    $dialog = [Microsoft.Win32.OpenFileDialog]::new()
    $dialog.Title = L '&#x9009;&#x62E9; PDF' 'Choose PDF'
    $dialog.Filter = 'PDF files (*.pdf)|*.pdf'
    if ($dialog.ShowDialog() -eq $true) {
        Set-SelectedPdf $dialog.FileName
    }
}

function Open-VisualCrop {
    try {
        Assert-Runtime
        $args = @('-Xms128m', '-Xmx1024m', '-jar', (Quote-Arg $Jar))
        if (-not [string]::IsNullOrWhiteSpace($script:SelectedPdf)) {
            $args += (Quote-Arg $script:SelectedPdf)
        }
        Start-Process -FilePath $Javaw -ArgumentList $args -WorkingDirectory $RootDir
        Set-Status '&#x53EF;&#x89C6;&#x5316;&#x88C1;&#x526A;&#x5DE5;&#x4F5C;&#x53F0;&#x5DF2;&#x6253;&#x5F00;&#x3002;' 'Visual crop workspace opened.' 'Good'
    } catch {
        [Windows.MessageBox]::Show($_.Exception.Message, 'PDFCut Studio', 'OK', 'Error') | Out-Null
        Set-Status '&#x6253;&#x5F00;&#x53EF;&#x89C6;&#x5316;&#x88C1;&#x526A;&#x5931;&#x8D25;&#x3002;' 'Failed to open Visual Crop.' 'Warn'
    }
}

function Run-AutoCrop {
    try {
        Assert-Runtime
        if ([string]::IsNullOrWhiteSpace($script:SelectedPdf)) {
            Choose-Pdf
        }
        if ([string]::IsNullOrWhiteSpace($script:SelectedPdf)) {
            return
        }

        $dest = Join-Path $OutputDir ([IO.Path]::GetFileNameWithoutExtension($script:SelectedPdf) + '_PDFCut.pdf')
        $psi = [Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $Java
        $psi.WorkingDirectory = $RootDir
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $psi.Arguments = Join-ProcessArgs @('-Xms128m', '-Xmx1024m', '-jar', $Jar, '-s', $script:SelectedPdf, '-d', $dest)

        Set-Status '&#x6B63;&#x5728;&#x81EA;&#x52A8;&#x88C1;&#x526A;&#xFF0C;&#x8BF7;&#x7A0D;&#x5019;&#x2026;' 'Auto cropping. Please wait...' 'Busy'
        $script:ChooseButton.IsEnabled = $false
        $script:VisualButton.IsEnabled = $false
        $script:AutoButton.IsEnabled = $false
        $process = [Diagnostics.Process]::Start($psi)
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $dest)) {
            $message = ($stderr + [Environment]::NewLine + $stdout).Trim()
            if ([string]::IsNullOrWhiteSpace($message)) { $message = 'Auto crop failed.' }
            throw $message
        }
        $script:OutputText.Text = $dest
        Set-Status '&#x88C1;&#x526A;&#x5B8C;&#x6210;&#xFF0C;&#x5DF2;&#x8F93;&#x51FA;&#x5230; output &#x76EE;&#x5F55;&#x3002;' 'Crop complete. The file was written to output.' 'Good'
    } catch {
        [Windows.MessageBox]::Show($_.Exception.Message, 'PDFCut Studio', 'OK', 'Error') | Out-Null
        Set-Status '&#x81EA;&#x52A8;&#x88C1;&#x526A;&#x5931;&#x8D25;&#x3002;' 'Auto crop failed.' 'Warn'
    } finally {
        $script:ChooseButton.IsEnabled = $true
        $script:VisualButton.IsEnabled = $true
        $script:AutoButton.IsEnabled = $true
    }
}

function Open-Output {
    Start-Process explorer.exe -ArgumentList (Quote-Arg $OutputDir) | Out-Null
}

function Open-Guide {
    if (Test-Path -LiteralPath $Guide) {
        Start-Process explorer.exe -ArgumentList (Quote-Arg $Guide) | Out-Null
    }
}

function Apply-Language {
    $window.Title = "PDFCut Studio $AppVersion"
    $script:VersionText.Text = "v$AppVersion"
    Set-ControlText 'TaglineText' 'Visual PDF cropping with secure content cutting'
    Set-ControlText 'SafeTitleText' 'Secure crop'
    Set-ControlText 'SafeBodyText' 'Uses MuPDF content clipping to keep selectable text inside the crop area and physically remove content outside it.'
    Set-ControlText 'FastTitleText' 'Fast crop'
    Set-ControlText 'FastBodyText' 'Keeps the legacy PDF boundary-box workflow for the smallest and quickest output when physical content removal is not required.'
    Set-ControlText 'LocalText' 'Local only - Portable runtime'
    Set-ControlText 'LanguageLabel' 'Language'
    Set-ControlText 'HeaderTitleText' 'Crop Workspace'
    Set-ControlText 'HeaderSubtitleText' 'Choose a PDF, then open Visual Crop or run one-click automatic processing.'
    Set-ControlText 'DropTitle' 'Drop a PDF here or click to choose'
    Set-ControlText 'DropSubtitleText' 'All processing runs locally. Output files are written to the output folder by default.'
    Set-ControlText 'FileNameText' 'No file selected'
    Set-ControlText 'ChooseButton' 'Choose PDF'
    Set-ControlText 'VisualButton' 'Open Visual Crop'
    Set-ControlText 'AutoButton' 'Auto Crop'
    Set-ControlText 'OutputButton' 'Open Output Folder'
    Set-ControlText 'LogicTitleText' 'Recommended output logic'
    Set-ControlText 'LogicBodyText' 'In the Visual Crop window, use "Secure crop: visible area only": text inside the crop remains selectable, while content outside the crop is removed.'
    Set-ControlText 'GuideButton' 'Quick Start'

    if (-not [string]::IsNullOrWhiteSpace($script:SelectedPdf)) {
        $script:DropTitle.Text = L '&#x5DF2;&#x9009;&#x62E9; PDF' 'PDF selected'
        $script:FileNameText.Text = [IO.Path]::GetFileName($script:SelectedPdf)
        $script:FilePathText.Text = $script:SelectedPdf
    }

    if (-not [string]::IsNullOrWhiteSpace($script:LastStatusZh)) {
        $script:StatusText.Text = L $script:LastStatusZh $script:LastStatusEn
    }
}

$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PDFCut Studio 1.0.0"
    Width="1080"
    Height="680"
    MinWidth="940"
    MinHeight="600"
    WindowStartupLocation="CenterScreen"
    Background="#F7F9FC"
    FontFamily="Microsoft YaHei UI"
    FontSize="14"
    UseLayoutRounding="True"
    SnapsToDevicePixels="True"
    TextOptions.TextFormattingMode="Display"
    TextOptions.TextRenderingMode="ClearType">
    <Window.Resources>
        <DropShadowEffect x:Key="SoftShadow" Color="#0F172A" BlurRadius="18" ShadowDepth="2" Opacity="0.10"/>
        <Style x:Key="AppButton" TargetType="Button">
            <Setter Property="Height" Value="46"/>
            <Setter Property="Padding" Value="18,0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Background" Value="#FFFFFF"/>
            <Setter Property="Foreground" Value="#0F172A"/>
            <Setter Property="BorderBrush" Value="#D5DDE8"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Border"
                                CornerRadius="8"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#F8FAFC"/>
                                <Setter TargetName="Border" Property="BorderBrush" Value="#94A3B8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#E2E8F0"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Border" Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource AppButton}">
            <Setter Property="Background" Value="#0F766E"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#0F766E"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="300"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0" Background="#0F172A">
            <Grid Margin="28">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel>
                    <Border Width="52" Height="52" CornerRadius="12" Background="#14B8A6" HorizontalAlignment="Left">
                        <TextBlock Text="PDF" Foreground="#FFFFFF" FontSize="15" FontWeight="Bold"
                                   HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Text="PDFCut" Foreground="#FFFFFF" FontSize="34" FontWeight="Bold" Margin="0,22,0,0"/>
                    <TextBlock Text="Studio" Foreground="#99F6E4" FontSize="34" FontWeight="Bold" Margin="0,-6,0,0"/>
                    <TextBlock x:Name="VersionText" Text="v1.0.0" Foreground="#67E8F9" FontSize="13" FontWeight="SemiBold" Margin="0,8,0,0"/>
                    <TextBlock x:Name="TaglineText" Text="&#x53EF;&#x89C6;&#x5316; PDF &#x88C1;&#x526A;&#x4E0E;&#x5B89;&#x5168;&#x5185;&#x5BB9;&#x88C1;&#x5207;"
                               Foreground="#CBD5E1" FontSize="14" TextWrapping="Wrap" Margin="0,18,0,0" LineHeight="22"/>
                </StackPanel>

                <StackPanel Grid.Row="1" VerticalAlignment="Center">
                    <TextBlock x:Name="SafeTitleText" Text="&#x5B89;&#x5168;&#x88C1;&#x526A;" Foreground="#FFFFFF" FontSize="18" FontWeight="SemiBold"/>
                    <TextBlock x:Name="SafeBodyText" Text="&#x4F7F;&#x7528; MuPDF &#x5185;&#x5BB9;&#x88C1;&#x5207;&#xFF0C;&#x4FDD;&#x7559;&#x88C1;&#x526A;&#x533A;&#x5185;&#x53EF;&#x590D;&#x5236;&#x6587;&#x5B57;&#xFF0C;&#x7269;&#x7406;&#x79FB;&#x9664;&#x533A;&#x57DF;&#x5916;&#x5185;&#x5BB9;&#x3002;"
                               Foreground="#94A3B8" FontSize="13" TextWrapping="Wrap" LineHeight="22" Margin="0,10,0,0"/>
                    <TextBlock x:Name="FastTitleText" Text="&#x5FEB;&#x901F;&#x88C1;&#x526A;" Foreground="#FFFFFF" FontSize="18" FontWeight="SemiBold" Margin="0,32,0,0"/>
                    <TextBlock x:Name="FastBodyText" Text="&#x4FDD;&#x7559;&#x65E7;&#x7248; PDF &#x8FB9;&#x754C;&#x6846;&#x88C1;&#x526A;&#x903B;&#x8F91;&#xFF0C;&#x9002;&#x5408;&#x9700;&#x8981;&#x6700;&#x5C0F;&#x4F53;&#x79EF;&#x6216;&#x6700;&#x5FEB;&#x901F;&#x5EA6;&#x7684;&#x573A;&#x666F;&#x3002;"
                               Foreground="#94A3B8" FontSize="13" TextWrapping="Wrap" LineHeight="22" Margin="0,10,0,0"/>
                </StackPanel>

                <TextBlock x:Name="LocalText" Grid.Row="2" Text="&#x672C;&#x5730;&#x5904;&#x7406; - &#x5185;&#x7F6E;&#x4FBF;&#x643A;&#x8FD0;&#x884C;&#x65F6;" Foreground="#64748B" FontSize="12"/>
            </Grid>
        </Border>

        <Grid Grid.Column="1" Margin="38,34,38,34">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <DockPanel Grid.Row="0" LastChildFill="False">
                <StackPanel DockPanel.Dock="Left">
                    <TextBlock x:Name="HeaderTitleText" Text="&#x88C1;&#x526A;&#x5DE5;&#x4F5C;&#x53F0;" Foreground="#0F172A" FontSize="28" FontWeight="SemiBold"/>
                    <TextBlock x:Name="HeaderSubtitleText" Text="&#x9009;&#x62E9; PDF&#xFF0C;&#x7136;&#x540E;&#x76F4;&#x63A5;&#x6253;&#x5F00;&#x53EF;&#x89C6;&#x5316;&#x88C1;&#x526A;&#x6216;&#x4E00;&#x952E;&#x81EA;&#x52A8;&#x5904;&#x7406;&#x3002;"
                               Foreground="#64748B" Margin="0,7,0,0"/>
                </StackPanel>
                <StackPanel DockPanel.Dock="Right" Orientation="Horizontal" VerticalAlignment="Top">
                    <Border Background="#FFFFFF" BorderBrush="#D5DDE8" BorderThickness="1" CornerRadius="9" Padding="10,7" Margin="0,0,12,0">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock x:Name="LanguageLabel" Text="&#x8BED;&#x8A00;" Foreground="#475569" FontWeight="SemiBold" VerticalAlignment="Center" Margin="0,0,8,0"/>
                            <ComboBox x:Name="LanguageBox" Width="118" SelectedIndex="0">
                                <ComboBoxItem Tag="zh" Content="&#x4E2D;&#x6587;"/>
                                <ComboBoxItem Tag="en" Content="English"/>
                            </ComboBox>
                        </StackPanel>
                    </Border>
                    <Border Background="#ECFEFF" BorderBrush="#A5F3FC" BorderThickness="1"
                            CornerRadius="9" Padding="12,8">
                        <StackPanel Orientation="Horizontal">
                            <Ellipse x:Name="StatusDot" Width="8" Height="8" Fill="#64748B" Margin="0,0,8,0" VerticalAlignment="Center"/>
                            <TextBlock x:Name="StatusText" Text="&#x5C31;&#x7EEA;" Foreground="#475569" FontWeight="SemiBold"/>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </DockPanel>

            <Grid Grid.Row="1" Margin="0,30,0,24">
                <Grid.RowDefinitions>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border x:Name="DropZone" Grid.Row="0" Background="#FFFFFF" BorderBrush="#DDE5EF" BorderThickness="1"
                        CornerRadius="10" Padding="26" AllowDrop="True" Effect="{StaticResource SoftShadow}">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <StackPanel VerticalAlignment="Center">
                            <TextBlock x:Name="DropTitle" Text="&#x62D6;&#x5165; PDF &#x6216;&#x70B9;&#x51FB;&#x9009;&#x62E9;"
                                       Foreground="#0F172A" FontSize="27" FontWeight="SemiBold" TextAlignment="Center"/>
                            <TextBlock x:Name="DropSubtitleText" Text="&#x6240;&#x6709;&#x5904;&#x7406;&#x5747;&#x5728;&#x672C;&#x5730;&#x5B8C;&#x6210;&#x3002;&#x8F93;&#x51FA;&#x6587;&#x4EF6;&#x4F1A;&#x9ED8;&#x8BA4;&#x653E;&#x5165; output &#x76EE;&#x5F55;&#x3002;"
                                       Foreground="#64748B" FontSize="14" TextAlignment="Center" TextWrapping="Wrap"
                                       Margin="0,12,0,0" LineHeight="22"/>
                        </StackPanel>
                        <Border Grid.Row="1" Background="#F8FAFC" BorderBrush="#E2E8F0" BorderThickness="1"
                                CornerRadius="8" Padding="14" Margin="0,24,0,0">
                            <StackPanel>
                                <TextBlock x:Name="FileNameText" Text="&#x5C1A;&#x672A;&#x9009;&#x62E9;&#x6587;&#x4EF6;"
                                           Foreground="#0F172A" FontWeight="SemiBold" TextTrimming="CharacterEllipsis"/>
                                <TextBlock x:Name="FilePathText" Text="PDF" Foreground="#64748B" FontSize="12"
                                           TextTrimming="CharacterEllipsis" Margin="0,5,0,0"/>
                            </StackPanel>
                        </Border>
                    </Grid>
                </Border>

                <Grid Grid.Row="1" Margin="0,22,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Button x:Name="ChooseButton" Grid.Column="0" Style="{StaticResource AppButton}" Content="&#x9009;&#x62E9; PDF" Margin="0,0,10,0"/>
                    <Button x:Name="VisualButton" Grid.Column="1" Style="{StaticResource PrimaryButton}" Content="&#x6253;&#x5F00;&#x53EF;&#x89C6;&#x5316;&#x88C1;&#x526A;" Margin="10,0,10,0"/>
                    <Button x:Name="AutoButton" Grid.Column="2" Style="{StaticResource AppButton}" Content="&#x81EA;&#x52A8;&#x88C1;&#x526A;" Margin="10,0,10,0"/>
                    <Button x:Name="OutputButton" Grid.Column="3" Style="{StaticResource AppButton}" Content="&#x6253;&#x5F00;&#x8F93;&#x51FA;&#x76EE;&#x5F55;" Margin="10,0,0,0"/>
                </Grid>
            </Grid>

            <Border Grid.Row="2" Background="#FFFFFF" BorderBrush="#E2E8F0" BorderThickness="1" CornerRadius="10" Padding="18">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel>
                        <TextBlock x:Name="LogicTitleText" Text="&#x5EFA;&#x8BAE;&#x8F93;&#x51FA;&#x903B;&#x8F91;" Foreground="#0F172A" FontWeight="SemiBold"/>
                        <TextBlock x:Name="LogicBodyText" Text="&#x5728;&#x53EF;&#x89C6;&#x5316;&#x7A97;&#x53E3;&#x4E2D;&#x4F7F;&#x7528;&#x201C;&#x5B89;&#x5168;&#x88C1;&#x526A;&#xFF1A;&#x53EA;&#x8F93;&#x51FA;&#x53EF;&#x89C1;&#x533A;&#x57DF;&#x201D;&#xFF1A;&#x533A;&#x5185;&#x6587;&#x5B57;&#x53EF;&#x590D;&#x5236;&#xFF0C;&#x533A;&#x5916;&#x5185;&#x5BB9;&#x4F1A;&#x88AB;&#x79FB;&#x9664;&#x3002;"
                                   Foreground="#64748B" Margin="0,7,0,0" TextWrapping="Wrap" LineHeight="22"/>
                        <TextBlock x:Name="OutputText" Text="output" Foreground="#0F766E" FontSize="12" Margin="0,10,0,0" TextTrimming="CharacterEllipsis"/>
                    </StackPanel>
                    <Button x:Name="GuideButton" Grid.Column="1" Style="{StaticResource AppButton}" Content="&#x5FEB;&#x901F;&#x4E0A;&#x624B;" Width="118" Margin="18,0,0,0"/>
                </Grid>
            </Border>
        </Grid>
    </Grid>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$script:Language = 'zh'
$script:ChineseText = @{}
$script:LastStatusZh = $null
$script:LastStatusEn = $null
$script:SelectedPdf = $null
$script:VersionText = $window.FindName('VersionText')
$script:DropZone = $window.FindName('DropZone')
$script:DropTitle = $window.FindName('DropTitle')
$script:FileNameText = $window.FindName('FileNameText')
$script:FilePathText = $window.FindName('FilePathText')
$script:LanguageBox = $window.FindName('LanguageBox')
$script:StatusDot = $window.FindName('StatusDot')
$script:StatusText = $window.FindName('StatusText')
$script:OutputText = $window.FindName('OutputText')
$script:ChooseButton = $window.FindName('ChooseButton')
$script:VisualButton = $window.FindName('VisualButton')
$script:AutoButton = $window.FindName('AutoButton')
$script:OutputButton = $window.FindName('OutputButton')
$script:GuideButton = $window.FindName('GuideButton')

$script:ChooseButton.Add_Click({ Choose-Pdf })
$script:VisualButton.Add_Click({ Open-VisualCrop })
$script:AutoButton.Add_Click({ Run-AutoCrop })
$script:OutputButton.Add_Click({ Open-Output })
$script:GuideButton.Add_Click({ Open-Guide })
$script:LanguageBox.Add_SelectionChanged({
    if ($null -eq $script:LanguageBox.SelectedItem) {
        return
    }
    $script:Language = [string]$script:LanguageBox.SelectedItem.Tag
    Apply-Language
})
$script:DropZone.Add_MouseLeftButtonUp({ Choose-Pdf })
$script:DropZone.Add_DragOver({
    param($sender, $eventArgs)
    if ($eventArgs.Data.GetDataPresent([Windows.DataFormats]::FileDrop)) {
        $eventArgs.Effects = [Windows.DragDropEffects]::Copy
    } else {
        $eventArgs.Effects = [Windows.DragDropEffects]::None
    }
    $eventArgs.Handled = $true
})
$script:DropZone.Add_Drop({
    param($sender, $eventArgs)
    $files = $eventArgs.Data.GetData([Windows.DataFormats]::FileDrop)
    if ($files -and $files.Count -gt 0) {
        Set-SelectedPdf $files[0]
    }
})

Assert-Runtime
Apply-Language
Set-Status '&#x5C31;&#x7EEA;' 'Ready' 'Neutral'

if ($SelfTest) {
    $script:LanguageBox.SelectedIndex = 1
    if ([string]$script:ChooseButton.Content -ne 'Choose PDF') {
        throw 'Language switch self-test failed: English labels were not applied.'
    }
    $script:LanguageBox.SelectedIndex = 0
    if ([string]$script:ChooseButton.Content -ne (Ui '&#x9009;&#x62E9; PDF')) {
        throw 'Language switch self-test failed: Chinese labels were not restored.'
    }
    'PDFCut Studio self-test passed.'
    exit 0
}

[void]$window.ShowDialog()
