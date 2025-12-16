function Show-Tree {
    param (
        [string]$Path = ".",
        [string[]]$ExcludeTopLevel = @(),
        [int]$Level = 0
    )
    # Capturar la salida en una lista
    $output = @()

    # Solo al nivel raíz listamos los ficheros no vacíos en la raíz
    if ($Level -eq 0) {
        $rootFiles = Get-ChildItem -Path $Path -File | Where-Object { $_.Length -gt 3 }
        foreach ($file in $rootFiles) {
            $output += "├── " + $file.Name
        }
    }    
    
    # Obtener elementos, aplicando exclusión solo en el primer nivel
    if ($Level -eq 0) {
        $items = Get-ChildItem -Path $Path -Exclude $ExcludeTopLevel -File | Where-Object { $_.Length -gt 3 }
    } else {
        $items = Get-ChildItem -Path $Path -File | Where-Object { $_.Length -gt 3 }
    }
    
    foreach ($item in $items) {
        if ($Level -ne 0) { # Evitar duplicar los ficheros del nivel raíz
            $line = "  " + "  " * $Level + "├── " + $item.Name
            $output += $line
        }
    }
    
    # Obtener subdirectorios para continuar la recursión
    if ($Level -eq 0) {
        $dirs = Get-ChildItem -Path $Path -Directory -Exclude $ExcludeTopLevel
    } else {
        $dirs = Get-ChildItem -Path $Path -Directory
    }
    
    foreach ($dir in $dirs) {
        # Mostrar el directorio solo si tiene archivos no vacíos en algún nivel
        $subItems = Show-Tree -Path $dir.FullName -ExcludeTopLevel $ExcludeTopLevel -Level ($Level + 1)
        if ($subItems) {
            $output += "  " * $Level + "├── " + $dir.Name
            $output += $subItems
        }
    }
    
    return $output
}

# Ejecutar la función y mostrar la salida
Show-Tree -Path . -ExcludeTopLevel "android","build","ios","linux","macos","web","windows",".dart_tool",".idea",".vscode",".git"