# Proyecto Terraform - Infraestructura en Azure con Balanceador de Carga
```markdown

Este proyecto de Terraform despliega una infraestructura básica en Azure compuesta por:

- Red virtual y subred.
- Dirección IP pública.
- 3 máquinas virtuales Linux (Ubuntu) configuradas automáticamente con NGINX.
- Balanceador de carga Azure Load Balancer con backend pool.
- Asociación de las VMs al backend del Load Balancer.
- Almacenamiento remoto del estado en Azure Blob Storage.
```
---

##  Estructura del Proyecto
```
.
├── backend.tf
├── loadbalancer
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── main.tf
├── nsg
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── output.tf
├── provider.tf
├── variables.tf
├── vm
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── vnet
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

---

## Requisitos

- [Terraform CLI](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Una cuenta de Azure con permisos para crear recursos
- Un Storage Account y contenedor configurados para guardar el estado

---

## Backend Remoto

El estado de Terraform se almacena en un backend remoto en Azure Blob Storage, definido en el bloque:

```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "damacostoragestate"
    container_name       = "states"
    key                  = "estados.tfstate"
  }
}
```

Este enfoque permite trabajo colaborativo, consistencia en el estado y bloqueo automático.

---

##  Uso

1. Autenticarse con Azure:

```bash
az login
```

2. Inicializar Terraform:

```bash
terraform init
```

3. Revisar el plan de ejecución:

```bash
terraform plan
```

4. Aplicar los cambios:

```bash
terraform apply
```

5. Eliminar los recursos:

```bash
terraform destroy
```

---

## Qué se despliega

- Red virtual: `10.0.0.0/16`
- Subred: `10.0.1.0/24`
- IP Pública estática (Standard)
- 3 NICs dinámicas asociadas al backend pool
- 3 máquinas virtuales con Ubuntu 22.04 LTS
- NGINX instalado automáticamente
- Load Balancer con health probe y reglas de carga

---

## Seguridad

La contraseña de administrador para las máquinas virtuales se genera automáticamente con el recurso `random_password`, y se puede sobrescribir mediante la variable `password`.

---

## Notas

- Se recomienda incluir el archivo `.terraform.lock.hcl` en el repositorio para garantizar versiones consistentes.
- El directorio `.terraform/` y el archivo `terraform.tfstate` deben estar en `.gitignore`.
- Este proyecto usa `count = 3` para replicar los recursos y simular alta disponibilidad básica.
