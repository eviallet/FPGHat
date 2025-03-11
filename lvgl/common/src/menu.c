#ifdef BUILD_STM32
  #include "common/menu.h"
#else
  #include "common/inc/menu.h"
#endif

/* ==================================
                MODE
   ==================================
*/

static SCOPE_MODE current_mode = MODE_RUN;

static const char *mode_run_text = " Run";
#define MODE_RUN_COLOR 0x33CC00
static const char *mode_single_text = " Single";
#define MODE_SINGLE_COLOR 0xFFCC33
static const char *mode_stop_text = " Stop";
#define MODE_STOP_COLOR 0xFF0000

static lv_obj_t *mode_icon;
static lv_obj_t *mode_label;

void change_mode(SCOPE_MODE target_mode) {
    current_mode = target_mode;
    if(target_mode == MODE_RUN) {
        lv_label_set_text(mode_icon, LV_SYMBOL_PLAY);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_RUN_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_run_text);
    } else if(target_mode == MODE_SINGLE) {
        lv_label_set_text(mode_icon, LV_SYMBOL_NEXT);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_SINGLE_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_single_text);
    } else {
        lv_label_set_text(mode_icon, LV_SYMBOL_STOP);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_STOP_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_stop_text);
    }
}

void build_mode_item(lv_obj_t* inner_box) {
    mode_icon = lv_label_create(inner_box);
    lv_obj_set_style_text_font(mode_icon, &lv_font_montserrat_20, LV_STATE_DEFAULT);
    lv_obj_set_flex_align(mode_icon, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    mode_label = lv_label_create(inner_box);
    lv_obj_set_style_text_font(mode_label, &lv_font_montserrat_20, LV_STATE_DEFAULT);
    lv_obj_set_style_text_color(mode_label, lv_color_hex(MENU_ITEM_LABEL), LV_STATE_DEFAULT);
    lv_obj_set_flex_align(mode_label, LV_FLEX_ALIGN_END, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);

    change_mode(MODE_RUN);
}


void mode_callback(lv_event_t* event) {
    switch(current_mode) {
        case MODE_RUN:
            change_mode(MODE_SINGLE);
            return;
        case MODE_SINGLE:
            change_mode(MODE_STOP);
            return;
        case MODE_STOP:
            change_mode(MODE_RUN);
            return;
    }
}


/* ==================================
            TUNING BUTTONS
   ==================================
*/

bool are_tuning_buttons_shown = false;
lv_obj_t *btnParent;
lv_obj_t *btnUp;
lv_obj_t *btnDown;

lv_obj_t* create_tuning_button(BTN_TYPE type, lv_coord_t size) {
    lv_obj_t *btn = lv_btn_create(lv_scr_act());
    // Size and layout
    lv_obj_set_size(btn, size, size);
    // Styling
    lv_obj_set_style_bg_color(btn, lv_color_hex(MENU_ITEM_BKG), LV_STATE_DEFAULT);
    lv_obj_set_style_bg_color(btn, lv_color_hex(MENU_ITEM_BKG_SELECTED), LV_STATE_PRESSED);

    // Button icon
    lv_obj_t* label = lv_label_create(btn);
    // Size and layout
    lv_obj_set_flex_align(btn, LV_FLEX_FLOW_COLUMN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    // Contents
    lv_label_set_text(label, type == BTN_UP ? LV_SYMBOL_UP : LV_SYMBOL_DOWN);
    // Styling
    lv_obj_set_style_text_font(label, &lv_font_montserrat_26, LV_STATE_DEFAULT);
    lv_obj_set_style_text_color(label, lv_color_hex(MENU_ITEM_LABEL), LV_STATE_DEFAULT);
    // Interactions
    lv_obj_clear_flag(label, LV_OBJ_FLAG_CLICKABLE);

    // Item callback
    lv_obj_add_event_cb(btn, &tuning_button_callback, LV_EVENT_CLICKED, /* user_data */ NULL);

    // TODO hide buttons when clicking elsewhere

    return btn;
}

void tuning_button_handler(lv_event_t* caller) {
    lv_obj_t *attachedMenuItem = lv_event_get_current_target(caller);
    if(are_tuning_buttons_shown) {
        if(btnParent == attachedMenuItem) {
            hide_tuning_buttons(); // hide tuning buttons (toggle)
        } else {
            hide_tuning_buttons(); // hide other tuning buttons
            show_tuning_buttons(caller);
        }
    } else {
        show_tuning_buttons(caller);
    }
}

void show_tuning_buttons(lv_event_t* caller) {
    lv_obj_t *parent = lv_event_get_user_data(caller); // menu layout
    lv_obj_t *attachedMenuItem = lv_event_get_current_target(caller);

    lv_coord_t size = MENU_ITEM_WIDTH / 2;

    btnParent = attachedMenuItem;
    btnUp = create_tuning_button(BTN_UP, size);
    btnDown = create_tuning_button(BTN_DOWN, size);
    are_tuning_buttons_shown = true;

    lv_coord_t btnCoordX = lv_obj_get_x(parent) - size - MENU_HOR_MARGIN;
    lv_coord_t btnCoordY = lv_obj_get_y(attachedMenuItem) + lv_obj_get_height(attachedMenuItem) / 2;

    lv_obj_set_pos(
        btnUp,
        btnCoordX,
        btnCoordY - size - MENU_VER_MARGIN / 2
    );
    lv_obj_set_pos(
        btnDown,
        btnCoordX,
        btnCoordY + MENU_VER_MARGIN / 2
    );
}

void hide_tuning_buttons() {
    if(!are_tuning_buttons_shown) {
        return;
    }
    are_tuning_buttons_shown = false;
    lv_obj_del(btnUp);
    lv_obj_del(btnDown);
}

void tuning_button_callback(lv_event_t* event) {
    lv_obj_t *caller = lv_event_get_target(event);
    if(caller == btnUp) {
        increment_scale();
    }
    else if (caller == btnDown) {
        decrement_scale();
    }
}

/* ==================================
              TRIGGER
   ==================================
*/

void trigger_callback(lv_event_t* event) {
    tuning_button_handler(event);
    on_trigger_clicked();
    printf("Trigger");
}



/* ==================================
               SCALE
   ==================================
*/

#define SCALES_COUNT 9
static uint8_t current_scale = 4;
static float scale_values[SCALES_COUNT] = {
    0.01,
    0.02,
    0.05,
    0.1,
    0.2,
    0.5,
    1,
    2,
    5
};
static lv_obj_t *scale_label;

void scale_callback(lv_event_t* event) {
    tuning_button_handler(event);
    printf("Scale");
}

void increment_scale() {
    if(current_scale + 1 < SCALES_COUNT) {
        current_scale++;
        update_scale_item();
    }
}

void decrement_scale() {
    if(0 <= current_scale - 1) {
        current_scale--;
        update_scale_item();
    }
}

void build_scale_item(lv_obj_t* inner_box) {
    scale_label = lv_label_create(inner_box);
    lv_obj_set_style_text_font(scale_label, &lv_font_montserrat_20, LV_STATE_DEFAULT);
    lv_obj_set_style_text_color(scale_label, lv_color_hex(MENU_ITEM_LABEL), LV_STATE_DEFAULT);
    lv_obj_set_flex_align(scale_label, LV_FLEX_ALIGN_END, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    update_scale_item();
}

void update_scale_item() {
    float scale_value = scale_values[current_scale];
    lv_label_set_text_fmt(scale_label, "%.2f V/div", scale_value);
}

/* ==================================
               GLOBAL
   ==================================
*/

void create_menu_item(lv_obj_t* parent, const char* text, lv_callback callback) {
    // Menu item box
    lv_obj_t* item_box = lv_obj_create(parent);
    // Size and layout
    lv_obj_set_size(item_box, MENU_ITEM_WIDTH, MENU_ITEM_HEIGHT);
    lv_obj_set_flex_align(item_box, LV_FLEX_FLOW_COLUMN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    lv_obj_set_flex_flow(item_box, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_style_pad_ver(item_box, MENU_VER_MARGIN, LV_STATE_DEFAULT);
    lv_obj_set_style_pad_hor(item_box, MENU_HOR_MARGIN, LV_STATE_DEFAULT);
    // Styling
    lv_obj_set_scrollbar_mode(item_box, LV_SCROLLBAR_MODE_OFF);
    lv_obj_set_style_bg_color(item_box, lv_color_hex(MENU_ITEM_BKG), LV_STATE_DEFAULT);
    lv_obj_set_style_bg_color(item_box, lv_color_hex(MENU_ITEM_BKG_SELECTED), LV_STATE_PRESSED);
    // Shadow
    // lv_obj_set_style_shadow_color(item_box, lv_color_hex(0x000000), LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_spread(item_box, 2, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_width(item_box, 2, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_opa(item_box, LV_OPA_10, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_ofs_y(item_box, 2, LV_STATE_DEFAULT);

    // Menu item label
    lv_obj_t* label = lv_label_create(item_box);
    // Size and layout
    lv_obj_set_flex_align(label, LV_FLEX_FLOW_COLUMN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    // Contents
    lv_label_set_text(label, text);
    // Styling
    lv_obj_set_style_text_font(label, &lv_font_montserrat_26, LV_STATE_DEFAULT);
    lv_obj_set_style_text_color(label, lv_color_hex(MENU_ITEM_LABEL), LV_STATE_DEFAULT);
    // Interactions
    lv_obj_clear_flag(label, LV_OBJ_FLAG_CLICKABLE);

    // Inner box
    lv_obj_t* inner_box = lv_obj_create(item_box);
    // Size and layout
    lv_obj_set_size(inner_box, MENU_INNER_WIDTH, MENU_INNER_HEIGHT);
    lv_obj_set_style_pad_all(inner_box, 12, LV_STATE_DEFAULT);
    lv_obj_set_flex_flow(inner_box, LV_FLEX_FLOW_ROW);
    // Styling
    lv_obj_set_scrollbar_mode(inner_box, LV_SCROLLBAR_MODE_OFF);
    lv_obj_set_style_bg_color(inner_box, lv_color_hex(MENU_INNER_BKG), LV_STATE_DEFAULT);
    lv_obj_set_style_border_color(inner_box, lv_color_hex(MENU_INNER_BORDER), LV_STATE_DEFAULT);
    lv_obj_set_style_border_width(inner_box, MENU_INNER_BORDER_WIDTH, LV_STATE_DEFAULT);
    // Interactions
    lv_obj_clear_flag(inner_box, LV_OBJ_FLAG_CLICKABLE);

    // Item callback
    lv_obj_add_event_cb(item_box, *callback, LV_EVENT_CLICKED, /* user_data */ parent);

    if(IS_MENU_ITEM(text, MENU_ITEM_MODE)) {
        build_mode_item(inner_box);
    }
    else if(IS_MENU_ITEM(text, MENU_ITEM_SCALE)) {
        build_scale_item(inner_box);
    }
}


void create_menu(void) {
    MenuItem items[MENU_ITEM_COUNT] = {
        {
            .name = "Mode",
            .callback = mode_callback
        },
        {
            .name = "Trigger",
            .callback = trigger_callback
        },
        {
            .name = "Scale",
            .callback = scale_callback
        }
    };

    // Scrollable panel
    lv_obj_t * panel = lv_obj_create(lv_scr_act());
    // Size and layout
    lv_obj_set_size(panel, MENU_WIDTH, MENU_HEIGHT);
    lv_obj_set_pos(panel, MENU_X, 0);
    lv_obj_set_style_pad_all(panel, MENU_HOR_MARGIN, LV_STATE_DEFAULT);
    lv_obj_set_style_bg_color(panel, lv_color_hex(0x282C34), LV_STATE_DEFAULT);
    // Contents
    lv_obj_set_flex_flow(panel, LV_FLEX_FLOW_COLUMN);
    // Shadow
    lv_obj_set_style_shadow_color(panel, lv_color_hex(0x000000), LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_spread(panel, 5, LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_opa(panel, LV_OPA_10, LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_width(panel, 2, LV_STATE_DEFAULT);

    // Fill menu
    for(uint8_t i = 0; i < MENU_ITEM_COUNT; i++) {
        create_menu_item(panel, items[i].name, items[i].callback);
    }

}
