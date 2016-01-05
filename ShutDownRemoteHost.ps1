# Initialize Assemblies
Add-Type -AssemblyName PresentationFramework,system.windows.forms,System.Drawing

$thisScript=$MyInvocation.MyCommand
$scriptLocation=split-path $thisScript.path -parent

$defaultTextBox="Remote Computer IP or Name"

function New-MessageBox(){

    Param (

        $message,
        $title,
        $icon,
        $buttons
    )

    $messageBox = [System.Windows.Forms.MessageBox]::Show($message , $title , $buttons, $icon)
    return $messageBox

}

function Check-TextBoxOnClick(){

    $TextBoxContents=$tb_RemoteHost.Text

    if($TextBoxContents -eq $defaultTextBox){

        New-MessageBox -message "Please replace the default text with a valid host" -title "Enter valid host" -icon Error -buttons ok

    }
    else{

        if(Test-Connection -ComputerName $TextBoxContents -count 2 -quiet){

            cmd /c shutdown /m \\$TextBoxContents /r /t 00
            New-MessageBox -message "Restart command sent" -title "Command Sent" -icon Information -buttons OK

        }
        else{

            New-MessageBox -message "$TextBoxContents could not be contacted.  Please verify the Remote Host is online and reachable." -title "Host unable to be contacted" -icon Error -buttons ok

        }

    }



}


# Create the Main Form
$xaml = [XML](Get-Content “$scriptLocation\Assets\SDRHMain.xaml”)
$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
$mainform = [Windows.Markup.XamlReader]::Load($xamlReader)

# Define Form Elements
$tb_RemoteHost=$mainform.FindName('tb_RemoteHost')
$btn_Restart=$mainform.FindName('btn_Restart')

$tb_RemoteHost.add_KeyUp({if($_.key -eq "Enter"){Check-TextBoxOnClick}})
$btn_Restart.Add_Click({Check-TextBoxOnClick})

# Show the form
[void]$mainform.ShowDialog()