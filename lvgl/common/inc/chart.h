#ifndef CHART_H
#define CHART_H

#include "lvgl.h"

#ifdef BUILD_STM32
#else
    #include "lv_drv_conf.h"
#endif

#define SCOPE_CHART_WIDTH LV_HOR_RES * 4/5
#define SCOPE_CHART_HEIGHT LV_VER_RES

#define CHART_GRID_X 7
#define CHART_GRID_Y 7
#define CHART_GRID_0 3

#define CHART_GRID_WIDTH 4
#define CHART_BG_COLOR 0x21252B
#define CHART_GRID_MAJOR_COLOR 0x6A7A94
#define CHART_GRID_MINOR_COLOR 0x475162
#define CHART_CH1_COLOR 0xFFCC66
#define CHART_CH2_COLOR 0x98C279
#define CHART_CH3_COLOR 0x4FAAEF
#define CHART_CH4_COLOR 0xE06A5E

#define CHART_CH1 0
#define CHART_CH2 1

static void draw_event_cb(lv_event_t *e);
void add_data(uint8_t ser_index, int16_t x, int16_t y);
void create_scope_chart(void);

#endif