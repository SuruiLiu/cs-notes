#!/bin/bash

# 创建目录结构
mkdir -p docs/web-dev/{frontend,backend,database,server,security}
mkdir -p docs/infra/distributed
mkdir -p docs/infra/security
mkdir -p docs/web3/{blockchain,contracts,dapps,security}

# 模板内容
template_content='# 🚧 内容正在建设中...

!!! note "温馨提示"
    这部分内容正在精心编写中，敬请期待！
    
    如果您对这部分内容特别感兴趣，欢迎：
    
    1. 在 [GitHub Issues](https://github.com/SuruiLiu/cs-notes/issues) 中提出建议
    2. 通过 Pull Request 贡献内容
    3. 在 [Discussions](https://github.com/SuruiLiu/cs-notes/discussions) 中参与讨论

## 预计更新时间

预计将在两周内完成初稿，您可以：

- 点击右上角的 :star: Star 关注项目更新
- 通过 GitHub Watch 功能订阅更新通知'

# 创建模板文件
echo "$template_content" > docs/web-dev/frontend/index.md
echo "$template_content" > docs/web-dev/backend/index.md
echo "$template_content" > docs/web-dev/database/index.md
echo "$template_content" > docs/web-dev/server/index.md
echo "$template_content" > docs/web-dev/security/index.md
echo "$template_content" > docs/infra/distributed/index.md
echo "$template_content" > docs/infra/security/index.md
echo "$template_content" > docs/web3/blockchain/index.md
echo "$template_content" > docs/web3/contracts/index.md
echo "$template_content" > docs/web3/dapps/index.md
echo "$template_content" > docs/web3/security/index.md 