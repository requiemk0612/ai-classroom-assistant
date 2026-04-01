$root = 'D:\Projects\ai-classroom-assistant\public\demo\sample-gradient-pptx-src'
$pptx = 'D:\Projects\ai-classroom-assistant\public\demo\sample-gradient.pptx'

Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path -LiteralPath $root) {
  Remove-Item -LiteralPath $root -Recurse -Force
}

New-Item -ItemType Directory -Path $root | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root '_rels') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'docProps') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'ppt') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'ppt\_rels') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'ppt\slides') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'ppt\slides\_rels') | Out-Null

Set-Content -LiteralPath (Join-Path $root '[Content_Types].xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/slides/slide1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
  <Override PartName="/ppt/slides/slide2.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
  <Override PartName="/ppt/slides/slide3.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
'@

Set-Content -LiteralPath (Join-Path $root '_rels\.rels') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
'@

Set-Content -LiteralPath (Join-Path $root 'docProps\core.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>sample-gradient</dc:title>
  <dc:creator>Codex</dc:creator>
</cp:coreProperties>
'@

Set-Content -LiteralPath (Join-Path $root 'docProps\app.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Office PowerPoint</Application>
</Properties>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\presentation.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:sldIdLst>
    <p:sldId id="256" r:id="rId1"/>
    <p:sldId id="257" r:id="rId2"/>
    <p:sldId id="258" r:id="rId3"/>
  </p:sldIdLst>
</p:presentation>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\_rels\presentation.xml.rels') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide2.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide3.xml"/>
</Relationships>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\slides\slide1.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:sp><p:txBody><a:p><a:r><a:t>多元函数微分导入</a:t></a:r></a:p></p:txBody></p:sp>
      <p:sp><p:txBody><a:p><a:r><a:t>全微分描述局部线性变化。</a:t></a:r></a:p><a:p><a:r><a:t>方向导数表示沿指定方向的变化率。</a:t></a:r></a:p></p:txBody></p:sp>
    </p:spTree>
  </p:cSld>
</p:sld>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\slides\slide2.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:sp><p:txBody><a:p><a:r><a:t>梯度的核心结论</a:t></a:r></a:p></p:txBody></p:sp>
      <p:sp><p:txBody><a:p><a:r><a:t>梯度由各个偏导数组成。</a:t></a:r></a:p><a:p><a:r><a:t>梯度方向对应函数值增长最快的方向。</a:t></a:r></a:p></p:txBody></p:sp>
    </p:spTree>
  </p:cSld>
</p:sld>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\slides\slide3.xml') -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:sp><p:txBody><a:p><a:r><a:t>几何理解</a:t></a:r></a:p></p:txBody></p:sp>
      <p:sp><p:txBody><a:p><a:r><a:t>在等高线图上，梯度与等高线垂直。</a:t></a:r></a:p><a:p><a:r><a:t>梯度模等于最大方向导数。</a:t></a:r></a:p></p:txBody></p:sp>
    </p:spTree>
  </p:cSld>
</p:sld>
'@

Set-Content -LiteralPath (Join-Path $root 'ppt\slides\_rels\slide1.xml.rels') -Encoding UTF8 -Value '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships" />'
Set-Content -LiteralPath (Join-Path $root 'ppt\slides\_rels\slide2.xml.rels') -Encoding UTF8 -Value '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships" />'
Set-Content -LiteralPath (Join-Path $root 'ppt\slides\_rels\slide3.xml.rels') -Encoding UTF8 -Value '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships" />'

if (Test-Path -LiteralPath $pptx) {
  Remove-Item -LiteralPath $pptx -Force
}

[System.IO.Compression.ZipFile]::CreateFromDirectory($root, $pptx)
Write-Output $pptx
