#ifndef STM32_2_CONFIG_H
#define STM32_2_CONFIG_H
#ifndef STM32_2_STAGE
#define STM32_2_STAGE 5
#endif
#if STM32_2_STAGE < 5 || STM32_2_STAGE > 7
#error "STM32_2_STAGE must be 5, 6 or 7"
#endif
#endif
