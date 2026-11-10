# BIM — Biblioteca dos Irmãos da Memphis

Aplicação para gerenciamento do acervo da Biblioteca dos Irmãos da Memphis. O sistema permite consultar livros, solicitar empréstimos e administrar solicitações, empréstimos e devoluções.

> **Status:** versão web publicada para validação. A versão Android ainda precisa passar pelas etapas de revisão, testes e preparação de distribuição descritas nas [Issues](../../issues).

## Visão geral

O BIM é composto por uma aplicação Flutter, uma API REST em FastAPI e um banco de dados PostgreSQL. A mesma base Flutter atende à experiência mobile e web.

### Funcionalidades implementadas

- Cadastro e autenticação de usuários.
- Autenticação baseada em JWT e identificação do perfil do usuário.
- Catálogo de livros e pesquisa.
- Visualização dos detalhes e disponibilidade dos livros.
- Solicitação de empréstimos.
- Fluxo administrativo para consultar, aprovar e rejeitar solicitações.
- Consulta de empréstimos e registro de devoluções.
- Favoritos.
- Controle de acesso a operações administrativas.
- Interface com identidade visual própria do BIM.

### Em desenvolvimento / validação para a versão Android

- Persistência de sessão e fluxo completo de logout.
- Finalização de informações e atalhos do painel do usuário.
- Revisão de navegação, mensagens, estados de carregamento e erros.
- Testes completos dos fluxos integrados ao ambiente de produção.
- Ajustes de layout e usabilidade em diferentes tamanhos de tela.
- Preparação, assinatura e validação do pacote Android para distribuição.

Acompanhe o progresso e as tarefas em aberto na área de [Issues](../../issues).

## Arquitetura

```text
Flutter (Android / Web)
          |
          v
       REST API
       FastAPI
          |
          v
     PostgreSQL
```

### Infraestrutura de hospedagem

| Componente | Tecnologia / serviço |
|---|---|
| Aplicação web | Firebase Hosting |
| API | Render |
| Banco de dados | Supabase PostgreSQL |

Os endereços públicos dos serviços não são listados neste README. As credenciais e configurações sensíveis devem permanecer em variáveis de ambiente, nunca no repositório.

## Tecnologias

**Frontend**
- Flutter
- Dart

**Backend**
- Python
- FastAPI
- SQLAlchemy
- Pydantic
- JWT

**Banco de dados**
- PostgreSQL
- Supabase

**Infraestrutura**
- Firebase Hosting
- Render
- Git e GitHub

## Estrutura do repositório

```text
book_archive/
├── backend/
│   ├── app/
│   │   ├── core/          # Segurança e configurações centrais
│   │   ├── models/        # Modelos SQLAlchemy
│   │   ├── routers/       # Rotas da API
│   │   └── ...
│   ├── requirements.txt
│   └── .env               # Configuração local; não versionar
├── mobile/
│   ├── android/
│   ├── lib/               # Código Dart/Flutter
│   ├── web/
│   ├── firebase.json
│   └── pubspec.yaml
└── README.md
```

## Executar o projeto localmente

### Pré-requisitos

- Python instalado.
- Flutter SDK instalado.
- Git.
- Acesso a uma instância PostgreSQL.

### 1. Backend

Na raiz do repositório:

```bash
cd backend
python -m venv venv
```

No Windows PowerShell, ative o ambiente e instale as dependências:

```powershell
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Crie `backend/.env` com as configurações locais:

```env
DATABASE_URL=sua_url_de_conexao_postgresql
SECRET_KEY=sua_chave_secreta_forte
```

Inicie a API:

```bash
uvicorn app.main:app --reload
```

Por padrão, a API local fica disponível em `http://127.0.0.1:8000` e a documentação interativa em `http://127.0.0.1:8000/docs`.

### 2. Flutter

Em outro terminal:

```bash
cd mobile
flutter pub get
flutter run
```

Para executar no Chrome:

```bash
flutter run -d chrome
```

## Build e publicação web

Gere a versão web otimizada:

```bash
cd mobile
flutter build web --release
```

Os arquivos de publicação são gerados em `mobile/build/web`.

Com o Firebase CLI instalado e autenticado, publique a aplicação:

```bash
firebase deploy --only hosting
```

A configuração do Hosting utiliza `build/web` como diretório público.

## Segurança e configuração

- Nunca versione arquivos `.env`, senhas, tokens, chaves privadas ou keystores.
- Configure `DATABASE_URL` e `SECRET_KEY` por variáveis de ambiente no serviço de hospedagem.
- Restrinja o CORS às origens realmente utilizadas pela aplicação.
- Mantenha rotas administrativas protegidas no backend; esconder botões no frontend não substitui autorização na API.
- Não inclua credenciais reais em issues, commits, screenshots ou documentação.

## Plano de trabalho

O desenvolvimento é acompanhado por GitHub Issues. As issues registram o histórico do que já foi implementado e o trabalho restante para preparar a versão mobile.

Prioridades para a distribuição Android:
1. Fechar pendências de autenticação, sessão e regras de negócio.
2. Revisar experiência mobile e estados de interface.
3. Executar testes integrados usando o backend e banco hospedados.
4. Revisar segurança e configurações de produção.
5. Gerar, assinar e testar o pacote Android.
6. Preparar a distribuição escolhida (APK para distribuição direta ou AAB para Google Play).

## Observações sobre os planos gratuitos

Os provedores de hospedagem possuem cotas e políticas próprias. No plano gratuito, o backend pode entrar em suspensão após um período sem tráfego e o banco pode sofrer pausa por inatividade. O primeiro acesso após esses períodos pode apresentar demora.

---

**BIM — Biblioteca dos Irmãos da Memphis**
