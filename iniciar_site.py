#!/usr/bin/env python3
"""
SIGA - Site de Documentação
Script de inicialização para teste local

Uso:
    python iniciar_site.py              # Porta padrão (8080)
    python iniciar_site.py --porta 3000 # Porta customizada
    python iniciar_site.py --no-browser # Sem abrir navegador
"""

import http.server
import socketserver
import os
import sys
import socket
import webbrowser
import signal
import argparse
import threading
import time

# Configuracoes
PORTAS_TENTATIVA = [8080, 8081, 8082, 8083, 8084, 8085, 3000, 3001, 5000, 5500]
DIRETORIO_SITE = os.path.dirname(os.path.abspath(__file__))

# Cores para terminal (Windows e Unix)
class Cores:
    VERDE = '\033[92m'
    AMARELO = '\033[93m'
    VERMELHO = '\033[91m'
    AZUL = '\033[94m'
    NEGRITO = '\033[1m'
    RESET = '\033[0m'

def porta_disponivel(porta):
    """Verifica se uma porta está disponível."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind(("127.0.0.1", porta))
            return True
        except OSError:
            return False

def encontrar_porta_livre(porta_preferida=None):
    """Encontra uma porta livre, tentando a preferida primeiro."""
    if porta_preferida and porta_disponivel(porta_preferida):
        return porta_preferida
    if porta_preferida:
        print(f"{Cores.AMARELO}[AVISO] Porta {porta_preferida} em uso, buscando alternativa...{Cores.RESET}")
    for porta in PORTAS_TENTATIVA:
        if porta_disponivel(porta):
            return porta
    raise RuntimeError(f"{Cores.VERMELHO}[ERRO] Nenhuma porta livre encontrada!{Cores.RESET}")

def verificar_arquivos():
    """Verifica se os arquivos essenciais do site existem."""
    arquivos_essenciais = [
        'index.html',
        'modulos.html',
        'arquitetura.html',
        'diagramas.html',
        'processos.html',
        'seguranca.html',
        'downloads.html',
        'css/custom.css',
        'js/app.js',
    ]
    ausentes = []
    for arq in arquivos_essenciais:
        caminho = os.path.join(DIRETORIO_SITE, arq)
        if not os.path.exists(caminho):
            ausentes.append(arq)
    return ausentes

def exibir_banner(porta):
    """Exibe o banner de inicialização."""
    print()
    print(f"{Cores.AZUL}{'='*60}{Cores.RESET}")
    print(f"{Cores.NEGRITO}{Cores.VERDE}   SIGA - Sistema Integrado de Gestão de Almoxarifado{Cores.RESET}")
    print(f"{Cores.AZUL}   Site de Documentação Técnica - CBM-MT{Cores.RESET}")
    print(f"{Cores.AZUL}{'='*60}{Cores.RESET}")
    print()
    print(f"  {Cores.VERDE}Servidor ativo em:{Cores.RESET}")
    print(f"  {Cores.NEGRITO}http://localhost:{porta}{Cores.RESET}")
    print()
    print(f"  {Cores.AZUL}Páginas disponíveis:{Cores.RESET}")
    print(f"    - http://localhost:{porta}/index.html")
    print(f"    - http://localhost:{porta}/modulos.html")
    print(f"    - http://localhost:{porta}/arquitetura.html")
    print(f"    - http://localhost:{porta}/diagramas.html")
    print(f"    - http://localhost:{porta}/processos.html")
    print(f"    - http://localhost:{porta}/seguranca.html")
    print(f"    - http://localhost:{porta}/downloads.html")
    print()
    print(f"  {Cores.AMARELO}Pressione Ctrl+C para encerrar o servidor{Cores.RESET}")
    print(f"{Cores.AZUL}{'='*60}{Cores.RESET}")
    print()

class SIGAHandler(http.server.SimpleHTTPRequestHandler):
    """Handler customizado com logs limpos e MIME types corretos."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRETORIO_SITE, **kwargs)

    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        '.html': 'text/html; charset=utf-8',
        '.css': 'text/css; charset=utf-8',
        '.js': 'application/javascript; charset=utf-8',
        '.json': 'application/json; charset=utf-8',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.ico': 'image/x-icon',
        '.pdf': 'application/pdf',
        '.sql': 'text/plain; charset=utf-8',
        '.mp3': 'audio/mpeg',
        '.woff': 'font/woff',
        '.woff2': 'font/woff2',
        '.ttf': 'font/ttf',
        '.zip': 'application/zip',
    }

    def log_message(self, format, *args):
        """Log formatado com cores."""
        status = args[1] if len(args) > 1 else ''
        if str(status).startswith('2'):
            cor = Cores.VERDE
        elif str(status).startswith('3'):
            cor = Cores.AZUL
        elif str(status).startswith('4'):
            cor = Cores.AMARELO
        else:
            cor = Cores.VERMELHO
        print(f"  {cor}[{status}]{Cores.RESET} {args[0]}")

    def end_headers(self):
        """Adiciona headers para desenvolvimento (no-cache, CORS)."""
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

def abrir_navegador(porta, delay=1.5):
    """Abre o navegador após um breve delay."""
    def _abrir():
        time.sleep(delay)
        url = f"http://localhost:{porta}"
        print(f"  {Cores.AZUL}Abrindo navegador...{Cores.RESET}")
        webbrowser.open(url)
    thread = threading.Thread(target=_abrir, daemon=True)
    thread.start()

def main():
    parser = argparse.ArgumentParser(
        description='Servidor local para o site de documentação SIGA'
    )
    parser.add_argument(
        '--porta', '-p',
        type=int,
        default=None,
        help='Porta do servidor (padrão: 8080)'
    )
    parser.add_argument(
        '--no-browser', '-n',
        action='store_true',
        help='Não abrir o navegador automaticamente'
    )
    args = parser.parse_args()

    # Habilitar cores no Windows
    if sys.platform == 'win32':
        os.system('')  # Ativa suporte ANSI no cmd.exe

    # Verificar arquivos
    ausentes = verificar_arquivos()
    if ausentes:
        print(f"\n{Cores.AMARELO}[AVISO] Arquivos nao encontrados:{Cores.RESET}")
        for arq in ausentes:
            print(f"  - {arq}")
        print()

    # Encontrar porta
    porta_preferida = args.porta or 8080
    porta = encontrar_porta_livre(porta_preferida)

    # Iniciar servidor
    socketserver.TCPServer.allow_reuse_address = True
    try:
        servidor = socketserver.TCPServer(("", porta), SIGAHandler)
    except OSError as e:
        print(f"{Cores.VERMELHO}[ERRO] Nao foi possivel iniciar o servidor: {e}{Cores.RESET}")
        sys.exit(1)

    # Handler para Ctrl+C
    def encerrar(sig, frame):
        print(f"\n\n  {Cores.AMARELO}Encerrando servidor...{Cores.RESET}")
        servidor.shutdown()
        servidor.server_close()
        print(f"  {Cores.VERDE}Servidor encerrado com sucesso.{Cores.RESET}\n")
        sys.exit(0)

    signal.signal(signal.SIGINT, encerrar)

    # Exibir banner
    exibir_banner(porta)

    # Abrir navegador
    if not args.no_browser:
        abrir_navegador(porta)

    # Servir
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        encerrar(None, None)

if __name__ == '__main__':
    main()
