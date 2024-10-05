#!/bin/sh

set -e

# 指定例）C# 拡張機能 ms-dotnettools.csharp-2.45.25 の場合
# ./vscode_install_extension.sh /vscode/extensions ms-dotnettools csharp 2.45.25 linux-x64

# ※targetPlatform
#   win32-x64, win32-arm64, linux-x64, linux-arm64, linux-armhf, darwin-x64, darwin-arm64, alpine-x64, alpine-arm64, web
#   プラットフォームによって別れていない場合、指定すると逆にエラーになるので、その場合は指定しない。

extensions_dir=$1
publisher=$2
extension=$3
version=$4
targetPlatform=$5

# ダウンロード URL の生成
base_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$extension/$version/vspackage"
if [ -n "$targetPlatform" ]; then
    url="$base_url?targetPlatform=$targetPlatform"
else
    url="$base_url"
fi

# 一時フォルダ作成
tmp_dir=$(mktemp -d "/tmp/vscode_install_extension.XXXXXX")

# 指定の拡張機能のパッケージファイルをダウンロード
tmp_vspackage_gzip="$tmp_dir/vspackage.gzip"
wget "$url" -O "$tmp_vspackage_gzip"

# gzip を解凍して zip を取り出す
tmp_vspackage_zip="$tmp_dir/vspackage.zip"
gunzip -c "$tmp_vspackage_gzip" > "$tmp_vspackage_zip"
rm -f "$tmp_vspackage_gzip"

# zip を解凍して extension フォルダを取り出す
tmp_vspackage="$tmp_dir/vspackage"
unzip "$tmp_vspackage_zip" "extension/*" -d "$tmp_vspackage"

# extension フォルダをリネームしつつ vscode の拡張機能フォルダへ移動
base_dst_path="$extensions_dir/$publisher.$extension-$version"
if [ -n "$targetPlatform" ]; then
    dst_path="$base_dst_path-$targetPlatform"
else
    dst_path="$base_dst_path"
fi
mv "$tmp_vspackage/extension" "$dst_path"

# 一時フォルダ削除
rm -r "$tmp_dir"