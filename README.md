# BIM — Biblioteca dos Irmãos da Memphis

Sistema de gerenciamento de acervo e empréstimos de livros, desenvolvido para facilitar a consulta ao catálogo, a solicitação de empréstimos e a administração da biblioteca.

## Hospedagem

O aplicativo web, a API e o banco de dados estão hospedados em serviços de nuvem. Os endereços públicos de acesso não são listados neste README.

## Funcionalidades

- Cadastro e autenticação de usuários.
- Consulta ao catálogo de livros.
- Visualização dos detalhes e disponibilidade dos livros.
- Solicitação de empréstimos.
- Consulta e gerenciamento de solicitações pelo administrador.
- Registro e acompanhamento de empréstimos e devoluções.
- Favoritos.
- Controle de acesso conforme o perfil do usuário.

## Tecnologias

### Aplicação mobile e web
- Flutter
- Dart

### Backend
- Python
- FastAPI
- SQLAlchemy
- Autenticação com tokens JWT

### Banco de dados
- PostgreSQL
- Supabase

### Hospedagem e infraestrutura
- Firebase Hosting — aplicação Flutter Web
- Render — API FastAPI
- Supabase — banco de dados PostgreSQL

## Arquitetura

```text
Navegador / Aplicativo Flutter
             |
             v
       Firebase Hosting
       (Flutter Web)
             |
             v
       Render — FastAPI
             |
             v
     Supabase — PostgreSQL
```

A aplicação Flutter também pode ser executada em dispositivos Android. O frontend consome a API REST do backend, que acessa o banco PostgreSQL.

## Estrutura do projeto

```text
book_archive/
├── backend/
│   ├── app/
│   │   ├── core/
│   │   ├── models/
│   │   ├── routers/
│   │   └── ...
│   ├── requirements.txt
│   └── .env                 # Variáveis locais (não versionar)
├── mobile/
│   ├── android/
│   ├── lib/
│   ├── web/
│   ├── build/
│   ├── firebase.json
│   └── pubspec.yaml
└── README.md
```

## Executar localmente

### 1. Backend

Entre na pasta do backend:

```bash
cd backend
```

Crie e ative um ambiente virtual, instale as dependências e configure as variáveis de ambiente:

```bash
python -m venv venv
```

No Windows (PowerShell):

```powershell
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Crie um arquivo `.env` dentro de `backend/` com as configurações necessárias:

```env
DATABASE_URL=sua_url_de_conexao_postgresql
SECRET_KEY=gere_uma_chave_secreta_forte
```

Inicie a API:

```bash
uvicorn app.main:app --reload
```

Por padrão, a API local pode ser acessada em `http://127.0.0.1:8000`, e a documentação em `http://127.0.0.1:8000/docs`.

### 2. Aplicação Flutter

Em outro terminal:

```bash
cd mobile
flutter pub get
flutter run
```

Para executar no navegador:

```bash
flutter run -d chrome
```

## Gerar e publicar a versão web

Gere a versão de produção:

```bash
cd mobile
flutter build web --release
```

O resultado será gerado em `mobile/build/web`.

Para publicar no Firebase Hosting, com o Firebase CLI instalado e autenticado:

```bash
firebase deploy --only hosting
```

A configuração do Hosting utiliza `build/web` como diretório público.

## Variáveis de ambiente e segurança

- Não inclua arquivos `.env`, senhas, tokens ou chaves privadas no Git.
- Configure `DATABASE_URL` e `SECRET_KEY` como variáveis de ambiente no ambiente de hospedagem.
- Configure as origens permitidas do CORS para os domínios utilizados pela aplicação.
- Nunca utilize credenciais reais diretamente no código-fonte.

## Observações sobre o plano gratuito

Os serviços utilizados possuem limites e políticas próprias nos planos gratuitos. O Render pode suspender temporariamente o serviço após um período sem tráfego, e o Supabase pode pausar projetos gratuitos inativos. Assim, o primeiro acesso após um período de inatividade pode demorar.

---

Projeto BIM — Biblioteca dos Irmãos da Memphis.
