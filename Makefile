# Makefile para construir e enviar a gem active_act para o RubyGems

GEM_NAME = active_act
GEM_VERSION = 0.1.5
GEMSPEC = $(GEM_NAME).gemspec

.PHONY: all build push clean

# O alvo padrão
all: build

# Constrói a gem
build:
	@echo "Construindo a gem $(GEM_NAME) $(GEM_VERSION)..."
	gem build $(GEMSPEC)

# Faz o push da gem para o RubyGems
push: build
	@echo "Fazendo push da gem $(GEM_NAME) $(GEM_VERSION) para o RubyGems..."
	gem push $(GEM_NAME)-$(GEM_VERSION).gem

# Limpa arquivos gerados
clean:
	@echo "Removendo arquivos gerados..."
	rm -f $(GEM_NAME)-$(GEM_VERSION).gem