# C:\terminalSSH\connect_ssh.ps1
# EasySSH �{�̃X�N���v�g�i�ԍ��I���{�Θb������ҏW�E��/�|�[�g/�t�H���[�f�B���O�Ή��Eexit����ێ��j

$historyFile = "C:\terminalSSH\ssh_history.txt"

# ����ǂݍ��݁i��ɔz�񉻁j
$history = @()
if (Test-Path $historyFile) {
    $history = @(Get-Content $historyFile)
}

Write-Host "== EasySSH ==" -ForegroundColor Cyan

# ���C���I�����[�v
do {
    Write-Host "`n��������ڑ� (�ԍ��I��) / �V�K�ڑ� (n) / ����ҏW (e) ��I��ł��������F"
    for ($i = 0; $i -lt $history.Count; $i++) {
        $f = $history[$i] -split '\|'
        Write-Host "[$i] $($f[1])@$($f[0]):$($f[2])"
    }
    Write-Host "[n] �V�����ڑ���"
    Write-Host "[e] ����ҏW"

    $choice = Read-Host "�I��"

    if ($choice -eq 'e') {
        # �Θb������ҏW
        $flag=0
        do {
            Write-Host "`n-- ����ҏW���[�h --"
            Write-Host "[d] �w��폜  [c] �S�폜  [q] �ҏW�I��"
            $edit = Read-Host "����"
            switch ($edit) {
                'd' {
                    for ($j = 0; $j -lt $history.Count; $j++) {
                        $fj = $history[$j] -split '\|'
                        Write-Host "[$j] $($fj[0]):$($fj[2])"
                    }
                    $idx = Read-Host "�폜����ԍ�"
                    if ($idx -match '^\d+$' -and $idx -lt $history.Count) {
                        $history = $history | Where-Object { $_ -ne $history[$idx] }
                        $history | Set-Content $historyFile
                        Write-Host "����[$idx]���폜���܂����B" -ForegroundColor Green
                    } else {
                        Write-Host "�����Ȕԍ��ł��B" -ForegroundColor Red
                    }
                }
                'c' {
                    Clear-Content $historyFile
                    $history = @()
                    Write-Host "������S�폜���܂����B" -ForegroundColor Green
                }
                'q' {
                    $flag=1    # **�����̕ҏW���[�v�݂̂𔲂���**
                }
                default {
                    Write-Host "�����ȑ���ł��B" -ForegroundColor Red
                }
            }
        } while ($flag -ne 1)
        continue    # **���C�����[�v�ɖ߂�**
    }
    elseif ($choice -match '^\d+$' -and $choice -lt $history.Count) {
        # �o�^�ςݗ�������I��
        $f          = $history[$choice] -split '\|'
        $hostInput  = $f[0]
        $user       = $f[1]
        $port       = $f[2]
        $keyPath    = $f[3]
        $forwarding = $f[4]
        break
    }
    elseif ($choice -eq 'n') {
        # �V�K����
        do{
            $hostInput = Read-Host "�ڑ���z�X�g���܂���IP�����"
            if ($hostInput -match '^[a-zA-Z0-9.-]+$') { break } else { Write-Host "�����ȃz�X�g���ł��B" -ForegroundColor Red }   
        }while (-not $hostInput) 
        $user       = Read-Host "���[�U�[������͂��Ă��������i�f�t�H���g: ubuntu�j";  if (-not $user) { $user = "ubuntu" }
        $port       = Read-Host "�|�[�g�ԍ�����͂��Ă��������i�f�t�H���g: 22�j";   if (-not $port) { $port = "22" }
        $keyPath    = Read-Host "�閧���t�@�C���̃p�X����́i�󔒂Ȃ�p�X���[�h�F�؁j"
        $forwarding = Read-Host "�|�[�g�t�H���[�f�B���O�ݒ� (��: 8080:localhost:80)�i�󔒉j"
        break
    }
    else {
        Write-Host "�����ȑI���ł��B" -ForegroundColor Red
    }
} while ($true)

# SSH�R�}���h�g�ݗ���
$args = @()
if ($keyPath)    { $args += "-i `"$keyPath`"" }
$args += "-p $port"
$args += "$user@$hostInput"
if ($forwarding) { $args += "-L $forwarding" }

$command = "ssh " + ($args -join " ")
Write-Host "`n�� ���s: $command" -ForegroundColor Green

# ����ۑ��ihost|user|port|key|forwarding �`���A�d���o�^�Ȃ��j
$entryLine = "$hostInput|$user|$port|$keyPath|$forwarding"
if (-not $history -contains $entryLine) {
    Add-Content $historyFile $entryLine
}

# SSH���s�A�ؒf����ێ�
& ssh @args
Write-Host "`nSSH�ڑ����I�����܂����BEnter�L�[�������ƃE�B���h�E����܂��B" -ForegroundColor Cyan
Read-Host
