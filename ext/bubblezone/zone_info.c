#include "extension.h"

static void zone_info_free(void *pointer) {
  bubblezone_zone_info_t *zone_info = (bubblezone_zone_info_t *)pointer;

  if (zone_info->handle != 0) {
    bubblezone_free_zone_info(zone_info->handle);
  }

  xfree(zone_info);
}

static size_t zone_info_memsize(const void *pointer) {
  return sizeof(bubblezone_zone_info_t);
}

const rb_data_type_t zone_info_type = {
  .wrap_struct_name = "Bubblezone::ZoneInfo",
  .function = {
    .dmark = NULL,
    .dfree = zone_info_free,
    .dsize = zone_info_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};


VALUE zone_info_wrap(VALUE klass, unsigned long long handle) {
  bubblezone_zone_info_t *zone_info = ALLOC(bubblezone_zone_info_t);
  zone_info->handle = handle;
  return TypedData_Wrap_Struct(klass, &zone_info_type, zone_info);
}

static VALUE zone_info_start_x(VALUE self) {
  GET_ZONE_INFO(self, zone_info);
  return INT2NUM(bubblezone_zone_info_start_x(zone_info->handle));
}

static VALUE zone_info_start_y(VALUE self) {
  GET_ZONE_INFO(self, zone_info);
  return INT2NUM(bubblezone_zone_info_start_y(zone_info->handle));
}

static VALUE zone_info_end_x(VALUE self) {
  GET_ZONE_INFO(self, zone_info);
  return INT2NUM(bubblezone_zone_info_end_x(zone_info->handle));
}

static VALUE zone_info_end_y(VALUE self) {
  GET_ZONE_INFO(self, zone_info);
  return INT2NUM(bubblezone_zone_info_end_y(zone_info->handle));
}

static VALUE zone_info_is_zero(VALUE self) {
  GET_ZONE_INFO(self, zone_info);
  return bubblezone_zone_info_is_zero(zone_info->handle) ? Qtrue : Qfalse;
}

static VALUE zone_info_in_bounds(VALUE self, VALUE x, VALUE y) {
  GET_ZONE_INFO(self, zone_info);
  Check_Type(x, T_FIXNUM);
  Check_Type(y, T_FIXNUM);

  return bubblezone_zone_info_in_bounds(zone_info->handle, NUM2INT(x), NUM2INT(y)) ? Qtrue : Qfalse;
}

static VALUE zone_info_pos(VALUE self, VALUE x, VALUE y) {
  GET_ZONE_INFO(self, zone_info);
  Check_Type(x, T_FIXNUM);
  Check_Type(y, T_FIXNUM);

  int out_x, out_y;
  int success = bubblezone_zone_info_pos(zone_info->handle, NUM2INT(x), NUM2INT(y), &out_x, &out_y);

  if (!success) {
    return rb_ary_new_from_args(2, INT2NUM(-1), INT2NUM(-1));
  }

  return rb_ary_new_from_args(2, INT2NUM(out_x), INT2NUM(out_y));
}

static VALUE zone_info_alloc_error(VALUE klass) {
  rb_raise(rb_eTypeError, "allocator undefined for Bubblezone::ZoneInfo - use Manager#get instead");
  return Qnil;
}

void Init_bubblezone_zone_info(void) {
  cZoneInfo = rb_define_class_under(mBubblezone, "ZoneInfo", rb_cObject);

  rb_define_alloc_func(cZoneInfo, zone_info_alloc_error);
  rb_undef_method(rb_singleton_class(cZoneInfo), "new");

  rb_define_method(cZoneInfo, "start_x", zone_info_start_x, 0);
  rb_define_method(cZoneInfo, "start_y", zone_info_start_y, 0);
  rb_define_method(cZoneInfo, "end_x", zone_info_end_x, 0);
  rb_define_method(cZoneInfo, "end_y", zone_info_end_y, 0);
  rb_define_method(cZoneInfo, "zero?", zone_info_is_zero, 0);
  rb_define_method(cZoneInfo, "in_bounds?", zone_info_in_bounds, 2);
  rb_define_method(cZoneInfo, "pos", zone_info_pos, 2);
}
