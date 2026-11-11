-- ============================================================================
-- PRE-ENTREGA MÓDULO 4: CONSULTAS SQL DE NEGOCIO
-- Proyecto: RetailPro / TechStore
-- Base de Datos: Ventas_Tech_DB
-- Archivo: m4_consultas_negocio.sql
-- Motor: Microsoft SQL Server (T-SQL)
-- ============================================================================

USE Ventas_Tech_DB;
GO

-- ============================================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Objetivo: Medir facturación global, volumen de transacciones y ticket promedio
-- ============================================================================
-- Calcula el total facturado sumando (cantidad * precio_unitario), el conteo de
-- pedidos y el ticket promedio por mes comercial. Al estar todos los registros en
-- marzo de 2024, arroja 1 fila consolidada de control.

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
GO


-- ============================================================================
-- CONSULTA 2: RANKING DE PRODUCTOS (TOP 5)
-- Objetivo: Identificar los artículos que más aportan a la facturación
-- ============================================================================
-- Lista los 5 productos líderes en ingresos junto a su volumen total de unidades vendidas.

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO


-- ============================================================================
-- CONSULTA 3: CLIENTES RECURRENTES
-- Objetivo: Identificar compradores habituales (frecuencia de compra > 1)
-- ============================================================================
-- Filtra clientes que registraron más de una compra mediante HAVING COUNT(*) > 1,
-- mostrando cantidad de órdenes y total acumulado gastado.

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO


-- ============================================================================
-- CONSULTA 4: PRODUCTOS POR ENCIMA / POR DEBAJO DEL PROMEDIO
-- Objetivo: Clasificación de productos según el promedio de ventas por SKU
-- ============================================================================
-- Utiliza un CTE (WITH) para calcular primero el total generado por cada producto,
-- y luego clasifica cada uno contra el promedio general de facturación por producto.

WITH TotalesPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT 
    id_producto,
    total_producto,
    CASE 
        WHEN total_producto >= (SELECT AVG(total_producto) FROM TotalesPorProducto) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_vs_promedio
FROM TotalesPorProducto
ORDER BY total_producto DESC;
GO


-- ============================================================================
-- BLOQUE DE CIERRE: 3 HALLAZGOS ESTRATÉGICOS DE NEGOCIO
-- ============================================================================
/*
HALLAZGO 1 - Alta concentración de facturación en el Producto 1:
El id_producto 1 (Laptop Pro 15) es el líder absoluto de ingresos con $3,600.00
facturados (3 unidades vendidas a $1,200.00 cada una), representando el 63.8%
del total comercializado por la tienda en marzo ($5,640.00).

HALLAZGO 2 - Fidelidad y recurrencia de la base de clientes:
El 80% de los clientes analizados (4 de 5: IDs 1, 2, 3 y 4) son recurrentes
con exactamente 2 pedidos cada uno en el mes, concentrando el 83.2% del total
facturado ($4,690.00). El cliente 1 lidera el gasto con $2,640.00.

HALLAZGO 3 - Asimetría en el rendimiento del catálogo comercial:
El promedio de facturación por producto fue de $940.00. Solo 2 productos
(id_producto 1 con $3,600.00 e id_producto 3 con $1,350.00) se ubicaron 'Por encima'
del promedio, mientras que los 4 productos restantes quedaron 'Por debajo',
evidenciando una alta dependencia de las ventas de computadoras y monitores.
*/