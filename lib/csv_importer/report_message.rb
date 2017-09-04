module CSVImporter
  # Generate a human readable message for the given report.
  class ReportMessage
    def self.call(report)
      new(report).to_s
    end

    def initialize(report)
      @report = report
    end

    attr_accessor :report

    def to_s
      send("report_#{report.status}")
    end

    private

    def report_pending
      translate(:report_pending)
    end

    def report_in_progress
      translate(:report_in_progress)
    end

    def report_done
      translate(:report_done, details: import_details)
    end

    def report_invalid_header
      translate(:report_invalid_header, columns: report.missing_columns.join(', '), count: report.missing_columns.size)
    end

    def report_invalid_csv_file
      report.parser_error
    end

    def report_aborted
      translate(:report_aborted)
    end

    # Generate something like: "3 created. 4 updated. 1 failed to create. 2 failed to update."
    def import_details
      report.attributes
        .select { |name, _| name['_rows'] }
        .select { |_, instances| instances.size > 0 }
        .map { |bucket, instances| translate("buckets.#{bucket}", size: instances.size, count: instances.size) }
        .join(", ")
    end

    private

    def translate(key, base: 'csv_importer', **opts)
      I18n.t([base, key].compact.join('.'), opts)
    end
  end # class ReportMessage
end
