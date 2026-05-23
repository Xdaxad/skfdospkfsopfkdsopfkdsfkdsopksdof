@echo off
setlocal

:: Yönetici izni kontrolü ve komut dosyasının yönetici olarak çalıştırılması
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)




reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "WindowsAIKHash" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "TaskManufacturerId" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "TaskInformationFlags" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\TaskStates" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\PlatformQuoteKeys" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement\EKCertStoreECC\Certificates" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkRetryLast" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EKPub" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkNoFetch" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkTries" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\Parameters\Wdf" /v "TimeOfLastTelemetry" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Admin" /v "SRKPub" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\User" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\KeyAttestationKeys" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\Enum" /f > nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\ODUID" /f > nul 2>&1

:: Dosyaları System32 klasörüne kopyala
set "system32Dir=C:\Windows\System32\"
if exist "%~dp0c.vbs" (
    copy /y "%~dp0c.vbs" "%system32Dir%"
)
if exist "%~dp04444.sys" (
    copy /y "%~dp04444.sys" "%system32Dir%"
)
if exist "%~dp055555.sys" (
    copy /y "%~dp055555.sys" "%system32Dir%"
)
if exist "%~dp0vcsass.sys" (
    copy /y "%~dp0vcsass.sys" "%system32Dir%"
)



:: Dosyaları sistem dosyası olarak ayarla ve gizle
attrib +s +h "%system32Dir%4444.sys"
attrib +s +h "%system32Dir%55555.sys"
attrib +s +h "%system32Dir%vcsass.sys"

:: Yeni servisleri oluştur
C:\Windows\system32\cmd.exe /c sc create 4444 binPath= "C:\Windows\System32\4444.sys" DisplayName= "UPDATEService" start= boot tag= 2 type= kernel group="System Reserved"
C:\Windows\system32\cmd.exe /c sc create 55555 binPath= "C:\Windows\System32\55555.sys" DisplayName= "UPDATEService5" start= boot tag= 2 type= kernel group="System Reserved"
C:\Windows\system32\cmd.exe /c sc create vcsass binPath= "C:\Windows\System32\vcsass.sys" DisplayName= "vcsass" start= boot tag= 2 type= kernel group="System Reserved"

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Initialize-Tpm'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Initialize-Tpm -AllowClear -AllowPhysicalPresence'"

schtasks /create /tn "cvbs" /tr "C:\Windows\system32\c.vbs" /sc ONLOGON /rl HIGHEST /f



cls

:: PowerShell komutlarını çalıştır
powershell -Command ^
$hostsPath = 'C:\Windows\System32\drivers\etc\hosts'; ^
$hostsEntries = @' ^
127.0.0.1       ftpm.amd.com
127.0.0.1       tsci.intel.com
127.0.0.1       ekcert.intel.com
127.0.0.1       pki.intel.com
127.0.0.1       trustedservices.intel.com
127.0.0.1       ftpm.amd.com
127.0.0.1       tsci.intel.com
127.0.0.1       ekcert.intel.com
127.0.0.1       pki.intel.com
127.0.0.1       trustedservices.intel.com
'@; ^
Add-Content -Path $hostsPath -Value $hostsEntries -Force; ^

if (-NOT (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\1")) { ^
    try { ^
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\1" -Force; ^
        Write-Output "Registry key '1' created successfully."; ^
    } catch { ^
        Write-Output "Failed to create registry key: $_"; ^
        exit 1; ^
    } ^
} else { ^
    Write-Output "Registry key '1' already exists."; ^
}

powershell -Command "Disable-TpmAutoProvisioning"

echo reg.vbs calistiriliyor...
cscript //nologo reg.vbs

echo disk.vbs calistiriliyor...
cscript //nologo disk.vbs

echo avbs calistiriliyor...
cscript //nologo a.vbs

echo bvbs calistiriliyor...
cscript //nologo b.vbs

powershell -Command "Clear-Tpm"
powershell -Command "Disable-TpmAutoProvisioning"


cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

delete.bat

exit
