import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../providers/application_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch job details when screen loads
    Future.microtask(() {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final applicationProvider =
          Provider.of<ApplicationProvider>(context, listen: false);

      // Fetch job details
      jobProvider.fetchJobById(widget.jobId);

      // Check if user has already applied
      if (userProvider.currentUser != null) {
        applicationProvider.checkApplicationStatus(
            widget.jobId, userProvider.currentUser!.id);
      }
    });
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][date.month - 1];

    return '$month ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final job = jobProvider.selectedJob;
          if (job == null) {
            return const Center(child: Text('Job not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.company,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(job.description),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Consumer2<UserProvider, ApplicationProvider>(
                    builder:
                        (context, userProvider, applicationProvider, child) {
                      final user = userProvider.currentUser;

                      // If loading, show progress indicator
                      if (applicationProvider.isLoading) {
                        return const ElevatedButton(
                          onPressed: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // If already applied, show disabled button
                      if (applicationProvider.hasApplied) {
                        return const ElevatedButton(
                          onPressed: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Already Applied',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }

                      // Regular apply button
                      return ElevatedButton(
                        onPressed: () async {
                          // Check if user is logged in
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please log in to apply for jobs'),
                              ),
                            );
                            return;
                          }

                          // Prevent recruiters from applying to jobs
                          if (userProvider.isRecruiter) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Recruiters cannot apply for jobs'),
                              ),
                            );
                            return;
                          }

                          // Apply for the job
                          final success = await applicationProvider.applyForJob(
                            job.id,
                            user.id,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Application submitted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to submit application. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Apply Now',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
