#!/bin/bash

# -x: 実行したコマンドと引数も出力する
# -e: スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
# -E: '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
# -u: 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
# -o pipefail: パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する 
set -eEuo pipefail
shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

keys_dir=/etc/ssh/ssh_host_keys

generate_ssh_host_key() {
    key_type=$1
    key_file="${keys_dir}/ssh_host_${key_type}_key"
    if [ ! -f "${key_file}" ]; then
        ssh-keygen -t "${key_type}" -f "${key_file}" -N ''
    fi
}

generate_ssh_host_key rsa
generate_ssh_host_key ecdsa
generate_ssh_host_key ed25519
