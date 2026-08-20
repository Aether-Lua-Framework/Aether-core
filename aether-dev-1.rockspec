-- aether-dev-1.rockspec (for dev)
package = "aether-dev"
version = "dev-1"
source = { url = "..." } 
description = {
  summary = "Small enough to understand. Powerful enough to build. Dynamic enough to evolve.",
  license = "MIT",  
}
dependencies = {
  "lua >= 5.4",
  "cqueues",   --  sperate to aether-cqueues DLC later
}
build = {
  type = "builtin",
  modules = {}  -- src/ 구조라 luarocks 배포 시 매핑. 지금은 비워도 make로 돎.
}