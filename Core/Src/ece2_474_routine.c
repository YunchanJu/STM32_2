/* Preparation only: verify FPGA pins and PC echo on the real board. */
/* 2026-10-26 preparation: polling PC I/O and UART3 forwarding.
 * UART2 VCP and UART3 FPGA: 9600 baud, 8N1. No UART2 RX interrupt.
 */
#include "ece2_474.h"
#include "main.h"
#include "stm32_2_config.h"

volatile uint32_t g_rx_count = 0U;
volatile uint32_t g_tx_errors = 0U;
volatile uint8_t g_last_byte = 0U;

void ece2_474_init(void)
{
    printf("STM32_2 task %u ready: 9600 8N1\r\n", (unsigned)STM32_2_STAGE);
}

void polling_routine(void)
{
    int ch = getchar(); /* Wait for one byte; select None for line ending. */
    if (ch == EOF) return;
    uint8_t data = (uint8_t)ch;
    g_last_byte = data;
    ++g_rx_count;
    printf("RX char=%c hex=0x%02X\r\n",
           (data >= 32U && data <= 126U) ? (char)data : '.', (unsigned)data);
#if STM32_2_STAGE >= 6
    HAL_StatusTypeDef result = HAL_UART_Transmit(&huart3, &data, 1U, 100U);
    if (result != HAL_OK) ++g_tx_errors;
    printf("UART3 result=%d\r\n", (int)result);
    /* A zero result is local TX completion, not proof of FPGA reception. */
#endif
}

void HAL_GPIO_EXTI_Callback(uint16_t pin) { (void)pin; }
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *timer) { (void)timer; }
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *uart) { (void)uart; }
