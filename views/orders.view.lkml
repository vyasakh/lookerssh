view: orders {
  sql_table_name: demo_db.orders ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: ids {
    type: number
    sql: ${id}*${id}*${id}*101 ;;
    value_format_name: id
  }
  dimension_group: created {
    type: time
    convert_tz: no
    timeframes: [raw, time, date, week, month, quarter, year, day_of_week]
    sql: ${TABLE}.created_at ;;
  }
  dimension_group: created_date_friday {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: case when ${created_day_of_week} ='Friday' then ${created_date}
      when ${created_day_of_week} ='Saturday' then date_add(${created_date},interval 6 day)
      when ${created_day_of_week} ='Sunday' then date_add(${created_date},interval 5 day)
      when ${created_day_of_week} ='Monday' then date_add(${created_date},interval 4 day)
      when ${created_day_of_week} ='Tuesday' then date_add(${created_date},interval 3 day)
      when ${created_day_of_week} ='Wednesday' then date_add(${created_date},interval 2 day)
      when ${created_day_of_week} ='Thursday' then date_add(${created_date},interval 1 day)
      end ;;
  }

  parameter: date_granularity {
    type: string
    description: "To apply date granularity"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Quarter" }
    allowed_value: { value: "Year" }
  }

  dimension: created_date_granularity {
    type: date
    label_from_parameter: date_granularity
    sql:
    {% if date_granularity._parameter_value == 'day' %}
      ${created_date}
    {% elsif date_granularity._parameter_value == 'week' %}
      ${created_date_friday_date}
    {% elsif date_granularity._parameter_value == 'month' %}
      last_day(to_date(${created_date}),'month')
    {% endif %};;
  }


measure: ytd {
  label: "{{ _filters['created_date'] | date_add: 1, 'months' | date: '%Y-%m' }} to {{ _filters['created_date'] | date_add: 2, 'months' | date: '%Y-%m' }}"
  type: number
  value_format: "$#,##0.00"
}

  #   CASE
  #   WHEN {% parameter date_granularity %} = 'Day' THEN ${created_date}
  #   WHEN {% parameter date_granularity %} = 'Week' THEN ${created_date_friday_date}
  #   WHEN {% parameter date_granularity %} = 'Month' THEN ${created_month}
  #   WHEN {% parameter date_granularity %} = 'Quarter' THEN ${created_quarter}
  #   WHEN {% parameter date_granularity %} = 'Year' THEN ${created_year}
  #   else ${created_date}
  #   END ;;
  # }
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  users.id,
  users.first_name,
  users.last_name,
  billion_orders.count,
  fakeorders.count,
  hundred_million_orders.count,
  hundred_million_orders_wide.count,
  order_items.count,
  order_items_vijaya.count,
  ten_million_orders.count
  ]
  }

}
