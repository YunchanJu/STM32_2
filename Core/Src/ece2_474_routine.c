#include "ece2_474.h"
#include "main.h"
#include "stm32_2_config.h"

volatile uint32_t g_rx_count = 0U;
volatile uint32_t g_tx_errors = 0U;
volatile uint8_t g_last_byte = 0U;
volatile HAL_StatusTypeDef g_last_tx_status = HAL_OK;

void ece2_474_init(void)
{
    printf("STM32_2 task %u ready: 9600 8N1\r\n",
           (unsigned)STM32_2_STAGE);
}

void polling_routine(void)
{
    int ch = getchar();
    if (ch == EOF) return;

    uint8_t data = (uint8_t)ch;
    g_last_byte = data;
    ++g_rx_count;

#if STM32_2_STAGE == 5
    printf("RX char=%c hex=0x%02X\r\n",
           (data >= 32U && data <= 126U) ? (char)data : '.',
           (unsigned)data);
#else
    g_last_tx_status = HAL_UART_Transmit(&huart3, &data, 1U, 100U);
    if (g_last_tx_status != HAL_OK) ++g_tx_errors;
#if STM32_2_STAGE == 6
    printf("UART3 transmit byte 0x%02X, result: %d\r\n",
           (unsigned)data, (int)g_last_tx_status);
#else
    printf("UART3 command %c (0x%02X), result: %d\r\n",
           (data >= 32U && data <= 126U) ? (char)data : '.',
           (unsigned)data, (int)g_last_tx_status);
#endif
#endif
}

void HAL_GPIO_EXTI_Callback(uint16_t pin) { (void)pin; }
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *timer) { (void)timer; }
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *uart) { (void)uart; }
