.PHONY: setup infra infra-down start stop test typecheck validate demo clean

# Full setup: install deps, start infra, build, deploy BPMN, start process
setup: install infra build deploy-bpmn
	@echo ""
	@echo "Setup complete. Run 'make demo' to start the app and open a workflow."

# Install all npm dependencies
install:
	npm install

# Start Zeebe + Elasticsearch via Docker Compose
infra:
	docker compose up -d
	@echo "Waiting for Zeebe to be healthy..."
	@until curl -sf http://localhost:9600/actuator/health > /dev/null 2>&1; do sleep 2; done
	@echo "Zeebe is ready."

# Stop infrastructure
infra-down:
	docker compose down

# Build shared + BFF
build:
	npm run build

# Deploy BPMN process to Zeebe
deploy-bpmn:
	@curl -sf http://localhost:9600/actuator/health > /dev/null 2>&1 || (echo "Error: Zeebe not running. Run 'make infra' first." && exit 1)
	@echo "Starting BFF temporarily to deploy BPMN..."
	@CONTENTFUL_SPACE_ID=crakobzl4wgg \
	 CONTENTFUL_DELIVERY_TOKEN=L0VTqbNWRblOS0UieT0f1g4lu-Eu02KYF6s6G44-Qws \
	 ZEEBE_ADDRESS=localhost:26500 \
	 node packages/bff/dist/main.js &
	@sleep 3
	@curl -s -X POST http://localhost:3000/api/workflow/deploy | node -e "process.stdin.on('data',d=>console.log('BPMN deployed:',JSON.parse(d).deployed))"
	@kill $$(lsof -ti:3000) 2>/dev/null || true
	@sleep 1

# Start BFF + frontend (foreground)
start:
	@echo "Starting BFF on :3000 and frontend on :5174..."
	CONTENTFUL_SPACE_ID=crakobzl4wgg \
	CONTENTFUL_DELIVERY_TOKEN=L0VTqbNWRblOS0UieT0f1g4lu-Eu02KYF6s6G44-Qws \
	ZEEBE_ADDRESS=localhost:26500 \
	npx concurrently \
	  --names "bff,frontend" \
	  --prefix-colors "blue,green" \
	  "node packages/bff/dist/main.js" \
	  "npm run dev -w packages/frontend -- --port 5174"

# Stop app processes
stop:
	@lsof -ti:3000 | xargs kill -9 2>/dev/null || true
	@lsof -ti:5174 | xargs kill -9 2>/dev/null || true
	@echo "Stopped."

# Run all tests
test:
	npm test

# Run TypeScript type checking
typecheck:
	npm run typecheck

# Validate BPMN form references exist in Contentful
validate:
	CONTENTFUL_SPACE_ID=crakobzl4wgg \
	CONTENTFUL_DELIVERY_TOKEN=L0VTqbNWRblOS0UieT0f1g4lu-Eu02KYF6s6G44-Qws \
	npx ts-node --project packages/bff/tsconfig.json packages/bff/scripts/validate-bpmn-contentful.ts

# Full demo: start app, kick off a workflow, open browser
demo: start-bg start-workflow open

start-bg:
	@echo "Starting BFF + frontend in background..."
	@CONTENTFUL_SPACE_ID=crakobzl4wgg \
	 CONTENTFUL_DELIVERY_TOKEN=L0VTqbNWRblOS0UieT0f1g4lu-Eu02KYF6s6G44-Qws \
	 ZEEBE_ADDRESS=localhost:26500 \
	 node packages/bff/dist/main.js &
	@npm run dev -w packages/frontend -- --port 5174 &
	@sleep 3

start-workflow:
	@curl -s -X POST http://localhost:3000/api/workflow/start | node -e "process.stdin.on('data',d=>{const j=JSON.parse(d);console.log('Workflow started:',j.processInstanceKey)})"

open:
	@open http://localhost:5174 2>/dev/null || xdg-open http://localhost:5174 2>/dev/null || echo "Open http://localhost:5174 in your browser"

# Tear down everything
clean: stop infra-down
	@echo "All services stopped."
